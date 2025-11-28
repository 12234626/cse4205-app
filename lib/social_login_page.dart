import 'package:flutter/material.dart';
import 'constants.dart';
import 'services/auth_service.dart';
import 'signup_step_page.dart';

class SocialLoginPage extends StatefulWidget {
  const SocialLoginPage({super.key});

  @override
  State<SocialLoginPage> createState() => _SocialLoginPageState();
}

class _SocialLoginPageState extends State<SocialLoginPage> {
  bool _isLoading = false;

  Future<void> _handleLogin(String provider, String providerName) async {
    setState(() => _isLoading = true);

    try {
      await AuthService.authenticate(provider);
      await AuthService.login(provider);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$providerName 로그인 성공!')));

      // TODO: 서버에 accessToken을 보내서 신규/기존 회원 확인 필요
      // 임시로 로비로 이동
      Navigator.pushReplacementNamed(context, '/lobby');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$providerName 로그인 실패: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고 이미지
                  Image.asset(
                    'assets/images/logowithtext.png',
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        children: [
                          const Icon(Icons.error, size: 100, color: Colors.red),
                          Text('이미지 로드 실패: $error'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 80),

                  if (_isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    // 구글 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogin('google', 'Google'),
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text(
                          'Google로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 네이버 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogin('naver', 'Naver'),
                        icon: const Text(
                          'N',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        label: const Text(
                          'Naver로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF03C75A),
                          foregroundColor: Colors.white,
                          elevation: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogin('kakao', 'Kakao'),
                        icon: const Icon(Icons.chat_bubble, size: 24),
                        label: const Text(
                          'Kakao로 로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500),
                          foregroundColor: Colors.black87,
                          elevation: 1,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 회원가입 버튼
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupStepPage(),
                        ),
                      );
                    },
                    child: Text(
                      '계정이 없으신가요? 회원가입',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'guidelinesButton',
            onPressed: () => Navigator.pushNamed(context, '/guidelines'),
            tooltip: '가이드라인 페이지로 이동',
            child: const Icon(Icons.book),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'lobbyButton',
            onPressed: () => Navigator.pushNamed(context, '/lobby'),
            tooltip: '로비 페이지로 이동',
            child: const Icon(Icons.home),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'profileButton',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: '프로필 페이지로 이동',
            child: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }
}
