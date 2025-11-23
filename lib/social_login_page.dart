import 'package:flutter/material.dart';
import 'constants.dart';

class SocialLoginPage extends StatelessWidget {
  const SocialLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('로그인'),
      ),
      body: Center(
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
                ),
                const SizedBox(height: 80),

                // 구글 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 구글 로그인 처리
                      // 신규 회원이면 /signup-method로, 기존 회원이면 /lobby로
                      Navigator.pushNamed(context, '/signup-method');
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('구글 로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 카카오 로그인 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // 카카오 로그인 처리
                      // 신규 회원이면 /signup-method로, 기존 회원이면 /lobby로
                      Navigator.pushNamed(context, '/lobby');
                    },
                    icon: const Icon(Icons.chat_bubble),
                    label: const Text('카카오 로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFEE500),
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
              ],
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
