import 'package:flutter/material.dart';
import 'constants.dart';

class SignupInfoPage extends StatefulWidget {
  const SignupInfoPage({super.key});

  @override
  State<SignupInfoPage> createState() => _SignupInfoPageState();
}

class _SignupInfoPageState extends State<SignupInfoPage> {
  final _nicknameController = TextEditingController();
  String _selectedRole = '보호자';

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('회원가입'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '로그인 가입',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // 로그인 방법 표시
            const Text('로그인 방법', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('구글 로그인'),
            ),
            const SizedBox(height: 24),
            
            // 닉네임 입력
            const Text('닉네임', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                hintText: '닉네임',
                border: OutlineInputBorder(),
              ),
              onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 24),
            
            // 역할 선택
            const Text('역할', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('보호자'),
                    selected: _selectedRole == '보호자',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRole = '보호자');
                      }
                    },
                    selectedColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('아이'),
                    selected: _selectedRole == '아이',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRole = '아이');
                      }
                    },
                    selectedColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // 시작하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 역할에 따라 다른 로비로 이동
                  if (_selectedRole == '보호자') {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/lobby-parent',
                      (route) => false,
                    );
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/lobby',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('시작하기', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
