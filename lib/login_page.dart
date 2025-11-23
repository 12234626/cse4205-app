import 'package:flutter/material.dart';
import 'constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('로그인 페이지'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 이미지 (ID 입력창 가로 크기의 60%)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final logoSize = constraints.maxWidth * 0.6;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Image.asset(
                        'assets/images/tmplogo.png',
                        width: logoSize,
                        height: logoSize,
                        fit: BoxFit.contain,
                      ),
                    );
                  },
                ),
                TextField(
                  controller: _idController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'ID입력칸',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pwController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: '비밀번호입력칸',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      tooltip: _obscure ? '비밀번호 보기' : '비밀번호 숨기기',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(thickness: 1.0),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _showSnack('ID 찾기 눌림'),
                      child: const Text('ID찾기'),
                    ),
                    TextButton(
                      onPressed: () => _showSnack('비밀번호 찾기 눌림'),
                      child: const Text('비밀번호찾기'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final id = _idController.text.trim();
                      final pw = _pwController.text;
                      _showSnack('간편로그인: id="$id" pw 길이=${pw.length}');
                    },
                    child: const Text('간편로그인'),
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
