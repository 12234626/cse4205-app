import 'package:flutter/material.dart';
import '../../common/constants.dart';

class SignupMethodPage extends StatelessWidget {
  const SignupMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('소셜 로그인 진행 (신규 회원)'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '로그인 방법',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),

                // 로그인 방법 설명
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('P', style: TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(Icons.arrow_forward, size: 40),
                    const SizedBox(width: 20),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'P',
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('로그인 방법'),
                const SizedBox(height: 60),

                // 구글 로그인 버튼
                Card(
                  color: const Color(0xFFE8D5F2),
                  child: ListTile(
                    leading: const Icon(Icons.circle_outlined),
                    title: const Text('구글 로그인'),
                    onTap: () {
                      Navigator.pushNamed(context, '/signup-info');
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // 카카오 로그인 버튼
                Card(
                  color: const Color(0xFFE8D5F2),
                  child: ListTile(
                    leading: const Icon(Icons.circle_outlined),
                    title: const Text('카카오 로그인'),
                    onTap: () {
                      Navigator.pushNamed(context, '/signup-info');
                    },
                  ),
                ),
                const SizedBox(height: 40),

                // 시작하기 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup-info');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8D5F2),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_circle_outline),
                        SizedBox(width: 8),
                        Text('시작하기', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
