import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'api_service.dart';

class AuthService {
  AuthService._();

  static const _storage = FlutterSecureStorage();

  static String _getTokenKey(String provider) => '${provider}_token';

  static Future<String?> _getToken(String provider) async {
    return await _storage.read(key: _getTokenKey(provider));
  }

  static Future<void> _clearLocalData() async {
    await _storage.deleteAll();
    await GoogleSignIn.instance.signOut();
    await FlutterNaverLogin.logOut();
    await UserApi.instance.logout();
    await ApiService.setToken(null, null);
  }

  static Future<void> authenticate(String provider) async {
    String? token;

    switch (provider) {
      case 'google':
        await GoogleSignIn.instance.initialize();

        final GoogleSignInAccount account = await GoogleSignIn.instance
            .authenticate();
        final GoogleSignInClientAuthorization? authorization = await account
            .authorizationClient
            .authorizationForScopes(['profile']);

        token = authorization?.accessToken;

        break;

      case 'naver':
        await FlutterNaverLogin.logIn();

        final naverToken = await FlutterNaverLogin.getCurrentAccessToken();

        if (naverToken.isValid()) {
          token = naverToken.accessToken;
        }

        break;

      case 'kakao':
        final oauthToken = await isKakaoTalkInstalled()
            ? await UserApi.instance.loginWithKakaoTalk()
            : await UserApi.instance.loginWithKakaoAccount();

        token = oauthToken.accessToken;

        break;

      default:
        throw Exception('INVALID_PROVIDER');
    }

    if (token == null) {
      throw Exception('INVALID_TOKEN');
    }

    await _storage.write(key: _getTokenKey(provider), value: token);
  }

  static Future<void> login(String provider) async {
    try {
      final response = await ApiService.post(
        '/api/auth/login',
        body: {'provider': provider, 'token': await _getToken(provider)},
      );

      if (!response.success) {
        throw Exception(response.error);
      }

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      await ApiService.setToken(accessToken, refreshToken);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> register(
    String provider,
    String username,
    String role,
  ) async {
    try {
      final response = await ApiService.post(
        '/api/auth/register',
        body: {
          'provider': provider,
          'token': await _getToken(provider),
          'username': username,
          'role': role,
        },
      );

      if (!response.success) {
        throw Exception(response.error);
      }

      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];

      await ApiService.setToken(accessToken, refreshToken);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    await ApiService.post('/api/auth/logout');
    await _clearLocalData();
  }

  static Future<void> logoutAll() async {
    await ApiService.post('/api/auth/logout-all');
    await _clearLocalData();
  }
}
