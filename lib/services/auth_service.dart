import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class AuthService {
  AuthService._();

  static Future<String?> _getAccessToken(String provider) async {
    switch (provider) {
      case 'google':
        await GoogleSignIn.instance.initialize();

        final GoogleSignInAccount account = await GoogleSignIn.instance
            .authenticate();
        final GoogleSignInClientAuthorization? authorization = await account
            .authorizationClient
            .authorizationForScopes(['profile', 'email']);

        return authorization?.accessToken;

      case 'naver':
        await FlutterNaverLogin.logIn();

        final token = await FlutterNaverLogin.getCurrentAccessToken();

        if (!token.isValid()) {
          return null;
        }
        return token.accessToken;

      case 'kakao':
        final token = await isKakaoTalkInstalled()
            ? await UserApi.instance.loginWithKakaoTalk()
            : await UserApi.instance.loginWithKakaoAccount();

        return token.accessToken;

      default:
        return null;
    }
  }

  static Future<String?> signIn(String provider) async {
    try {
      String? accessToken = await _getAccessToken(provider);

      if (accessToken == null) {
        throw Exception();
      }

      return accessToken;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signOut(String provider) async {
    switch (provider) {
      case 'google':
        await GoogleSignIn.instance.signOut();

        break;

      case 'naver':
        await FlutterNaverLogin.logOut();

        break;

      case 'kakao':
        await UserApi.instance.logout();

        break;

      default:
        throw Exception();
    }
  }
}
