import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

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
  static final List<Completer<void>> _requestQueue = [];

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

  static ResponseDto _formatResponse(http.Response response) {
    final rawBody = response.body;

    // 🔎 무조건 찍는 공통 로그 (나중에 필요 없으면 지워도 됨)
    print('================ [API RAW RESPONSE] ================');
    print('Method: ${response.request?.method}');
    print('URL: ${response.request?.url}');
    print('Status: ${response.statusCode}');
    print('Body length: ${rawBody.length}');
    // 너무 길면 앞 300자만 잘라서
    final preview = rawBody.length > 300
        ? rawBody.substring(0, 300) + '...'
        : rawBody;
    print('Body preview: "$preview"');
    print('====================================================');

    try {
      final decoded = json.decode(rawBody); // ← 실패하면 catch로 감

      if (decoded is Map<String, dynamic>) {
        return ResponseDto(
          decoded['statusCode'] as int? ?? response.statusCode,
          decoded['success'] as bool? ??
              (response.statusCode >= 200 && response.statusCode < 300),
          decoded['data'],
          decoded['error'],
          decoded['message'],
        );
      } else {
        // Map이 아니더라도 최소한 죽진 않게
        final success = response.statusCode >= 200 && response.statusCode < 300;
        return ResponseDto(response.statusCode, success, decoded, null, null);
      }
    } catch (e, stack) {
      // 🔥 바로 여기서 "누가 빈값 줬는지" 확인 가능
      print('******** JSON DECODE ERROR ********');
      print('Method: ${response.request?.method}');
      print('URL: ${response.request?.url}');
      print('Status: ${response.statusCode}');
      print('Body length: ${rawBody.length}');
      print('Body raw: "$rawBody"');
      print('Error: $e');
      print('Stack: $stack');
      print('***********************************');

      // 원래처럼 터뜨리고 싶으면 rethrow
      rethrow;
      // 아니면 여기서도 방어적으로 ResponseDto를 만들어 돌려줄 수도 있음
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _getToken('refresh');

      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh'),
        headers: await _getHeaders({}, 'refresh'),
      );
      final body = _formatResponse(response);

      if (body.success == true) {
        final accessToken = body.data['accessToken'];
        final refreshToken = body.data['refreshToken'];

        await setToken(accessToken, refreshToken);

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
    final ResponseDto body = _formatResponse(response);

    if (body.error == "UNAUTHORIZED") {
      if (_isRefreshing) {
        final completer = Completer<void>();

        _requestQueue.add(completer);
        await completer.future;

        return await request();
      }

      _isRefreshing = true;

      try {
        final success = await _refreshToken();

        for (Completer<void> completer in _requestQueue) {
          completer.complete();
        }

        if (!success) {
          await setToken(null, null);

          return response;
        }
        return await request();
      } catch (error) {
        for (Completer<void> completer in _requestQueue) {
          completer.completeError(error);
        }

        rethrow;
      } finally {
        _isRefreshing = false;
        _requestQueue.clear();
      }
    }

    return response;
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
    final fullUrl = '$_baseUrl$url';
    print('[API REQUEST] GET $fullUrl');

    return _request(() async {
      return await http.get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(headers),
      );
    });
  }

  static Future<ResponseDto> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final fullUrl = '$_baseUrl$url';
    print('[API REQUEST] POST $fullUrl');
    print('[API REQUEST BODY] $body');

    return _request(() async {
      return await http.post(
        Uri.parse(fullUrl),
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
    final fullUrl = '$_baseUrl$url';
    print('[API REQUEST] PUT $fullUrl');
    print('[API REQUEST BODY] $body');

    return _request(() async {
      return await http.put(
        Uri.parse(fullUrl),
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
    final fullUrl = '$_baseUrl$url';
    print('[API REQUEST] PATCH $fullUrl');
    print('[API REQUEST BODY] $body');

    return _request(() async {
      return await http.patch(
        Uri.parse(fullUrl),
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
    final fullUrl = '$_baseUrl$url';
    print('[API REQUEST] DELETE $fullUrl');
    print('[API REQUEST BODY] $body');

    return _request(() async {
      return await http.delete(
        Uri.parse(fullUrl),
        headers: await _getHeaders(headers),
        body: _getBody(body),
      );
    });
  }
}
