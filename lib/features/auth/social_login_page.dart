import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../services/auth_service.dart';
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
      // 소셜 로그인 인증
      await AuthService.authenticate(provider);

      // DB에 기존 회원 확인 (로그인 시도)
      try {
        await AuthService.login(provider);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$providerName 로그인 성공!')));

        // 기존 회원 → 로비로 이동
        Navigator.pushReplacementNamed(context, '/lobby');
      } catch (loginError) {
        // 로그인 실패 → 신규 회원 → 회원가입 페이지로 이동
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignupStepPage(provider: provider),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$providerName 인증 실패: ${e.toString()}')),
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
                        onPressed: () => _handleLogin('GOOGLE', 'Google'),
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
                          elevation: 6,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 네이버 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogin('NAVER', 'Naver'),
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
                          elevation: 6,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogin('KAKAO', 'Kakao'),
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
                          elevation: 6,
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.2),
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
            heroTag: 'lobbyButton',
            onPressed: () => Navigator.pushNamed(context, '/lobby'),
            tooltip: '로비 페이지로 이동',
            child: const Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}
