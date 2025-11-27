import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  ApiService._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'token';

  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';
  static Future<String?> get _token async => _storage.read(key: _tokenKey);

  static Future<void> setToken(String? token) async {
    if (token != null) {
      await _storage.write(key: _tokenKey, value: token);
    } else {
      await _storage.delete(key: _tokenKey);
    }
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  static Future<Map<String, String>> _getHeaders([
    Map<String, String>? headers,
  ]) async {
    final token = await _token;

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  static String _getBody(Object? body) {
    return body is String ? body : json.encode(body);
  }

  static Future<dynamic> get(String url, {Map<String, String>? headers}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$url'),
      headers: await _getHeaders(headers),
    );

    return await json.decode(response.body);
  }

  static Future<dynamic> post(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$url'),
      headers: await _getHeaders(headers),
      body: _getBody(body),
    );

    return await json.decode(response.body);
  }

  static Future<dynamic> put(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$url'),
      headers: await _getHeaders(headers),
      body: _getBody(body),
    );

    return await json.decode(response.body);
  }

  static Future<dynamic> patch(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl$url'),
      headers: await _getHeaders(headers),
      body: _getBody(body),
    );

    return await json.decode(response.body);
  }

  static Future<dynamic> delete(
    String url, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$url'),
      headers: await _getHeaders(headers),
      body: _getBody(body),
    );

    return await json.decode(response.body);
  }
}
