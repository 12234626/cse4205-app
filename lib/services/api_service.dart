import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../common/navigation.dart';

class ResponseDto {
  final int statusCode;
  final bool success;
  final dynamic data;
  final dynamic error;
  final dynamic message;

  ResponseDto(
    this.statusCode,
    this.success,
    this.data,
    this.error,
    this.message,
  );
}

class ApiService {
  ApiService._();

  static const _storage = FlutterSecureStorage();
  static bool _isRefreshing = false;
  static bool _isRedirectingToLogin = false;
  static final List<Completer<bool>> _refreshWaiters = [];

  static String _getTokenKey(String type) => '${type}_token';

  static Future<String?> _getToken(String type) async {
    return await _storage.read(key: _getTokenKey(type));
  }

  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  static Future<void> setToken(
    String? accessToken,
    String? refreshToken,
  ) async {
    if (accessToken != null && refreshToken != null) {
      await _storage.write(key: _getTokenKey('access'), value: accessToken);
      await _storage.write(key: _getTokenKey('refresh'), value: refreshToken);
      // ✅ 로그인/재발급 성공 시 리다이렉트 플래그 해제
      _isRedirectingToLogin = false;
    } else {
      await _storage.delete(key: _getTokenKey('access'));
      await _storage.delete(key: _getTokenKey('refresh'));
    }
  }

  static Future<Map<String, String>> _getHeaders([
    Map<String, String>? headers,
    String type = 'access',
  ]) async {
    final token = await _getToken(type);

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  static String? _getBody(Object? body) {
    return body == null
        ? null
        : body is String
        ? body
        : json.encode(body);
  }

  // ✅ JSON이 아닐 수 있는 응답(빈 문자열/HTML 등) 방어
  static Map<String, dynamic>? _tryDecodeMap(String body) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static ResponseDto _formatResponse(http.Response response) {
    final map = _tryDecodeMap(response.body);

    return ResponseDto(
      (map?['statusCode'] as int?) ?? response.statusCode,
      (map?['success'] as bool?) ?? false,
      map?['data'],
      map?['error'],
      map?['message'] ?? (map == null ? response.body : null),
    );
  }

  // ✅ 401 판단을 statusCode 우선으로
  static bool _isUnauthorized(http.Response response) {
    if (response.statusCode == 401) return true;
    final map = _tryDecodeMap(response.body);
    return map?['error'] == 'UNAUTHORIZED';
  }

  static void _goLoginAndClearStack() {
    if (_isRedirectingToLogin) return;
    _isRedirectingToLogin = true;

    // UI 프레임 이후 안전하게 네비게이션
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    });
  }

  static Future<void> _forceLogout() async {
    await setToken(null, null);
    _goLoginAndClearStack();
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getToken('refresh');

      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: await _getHeaders({}, 'refresh'),
      );
      if (response.statusCode == 401) return false;
      final body = _formatResponse(response);

      if (body.success == true) {
        if (body.data is! Map) return false;
        final accessToken = (body.data as Map)['accessToken'];
        final newRefreshToken = (body.data as Map)['refreshToken'];

        if (accessToken is! String || newRefreshToken is! String) return false;
        await setToken(accessToken, newRefreshToken);

        return true;
      }

      return false;
    } catch (error) {
      return false;
    }
  }

  static Future<http.Response> _handleResponse(
    http.Response response,
    Future<http.Response> Function() request,
  ) async {
    if (!_isUnauthorized(response)) return response;
    if (_isRedirectingToLogin) return response;

    // 누군가 refresh 중이면 기다렸다가 결과에 따라 처리
    if (_isRefreshing) {
      final waiter = Completer<bool>();
      _refreshWaiters.add(waiter);
      final ok = await waiter.future;

      if (!ok) {
        await _forceLogout();
        return response;
      }

      final retried = await request();
      // ✅ 재요청도 401이면 "항상 로그인 이동" 보장
      if (_isUnauthorized(retried)) {
        await _forceLogout();
      }
      return retried;
    }

    _isRefreshing = true;
    bool ok = false;

    try {
      ok = await _refreshToken();

      for (final w in _refreshWaiters) {
        if (!w.isCompleted) w.complete(ok);
      }

      if (!ok) {
        await _forceLogout();
        return response;
      }

      final retried = await request();
      if (_isUnauthorized(retried)) {
        await _forceLogout();
      }
      return retried;
    } catch (error) {
      for (final w in _refreshWaiters) {
        if (!w.isCompleted) w.complete(false);
      }
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshWaiters.clear();
    }
  }

  static Future<ResponseDto> _request(
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    final handledResponse = await _handleResponse(response, request);
    final body = _formatResponse(handledResponse);

    return body;
  }

  static Future<ResponseDto> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _request(() async {
      return await http.get(
        Uri.parse('$_baseUrl$url'),
        headers: await _getHeaders(headers),
      );
    });
  }

  static Future<ResponseDto> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _request(() async {
      return await http.post(
        Uri.parse('$_baseUrl$url'),
        headers: await _getHeaders(headers),
        body: _getBody(body),
      );
    });
  }

  static Future<ResponseDto> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _request(() async {
      return await http.put(
        Uri.parse('$_baseUrl$url'),
        headers: await _getHeaders(headers),
        body: _getBody(body),
      );
    });
  }

  static Future<ResponseDto> patch(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _request(() async {
      return await http.patch(
        Uri.parse('$_baseUrl$url'),
        headers: await _getHeaders(headers),
        body: _getBody(body),
      );
    });
  }

  static Future<ResponseDto> delete(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    return _request(() async {
      return await http.delete(
        Uri.parse('$_baseUrl$url'),
        headers: await _getHeaders(headers),
        body: _getBody(body),
      );
    });
  }
}
