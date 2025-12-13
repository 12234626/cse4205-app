import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'features/auth/social_login_page.dart';
import 'features/auth/signup_method_page.dart';
import 'features/auth/signup_info_page.dart';
import 'features/lobby/lobby_page.dart';
import 'features/profile/profile_page.dart';
import 'features/guide/guidelines.dart';
import 'features/profile/settings_page.dart';
import 'common/constants.dart';
import 'common/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  await Firebase.initializeApp();
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY']!);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '로그인 데모',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SocialLoginPage(),
        '/signup-method': (context) => const SignupMethodPage(),
        '/signup-info': (context) => const SignupInfoPage(),
        '/lobby': (context) => const LobbyPage(),
        '/profile': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return ProfilePage(username: args as String?);
        },
        '/guidelines': (context) => const GuidelinesPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // [ID입력칸]
                TextField(
                  controller: _idController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'ID입력칸',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // [비밀번호입력칸]
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
                // ------- (구분선)
                const Divider(thickness: 1.0),
                const SizedBox(height: 4),
                // [ID찾기] [비밀번호찾기]
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
                // [간편로그인] (버튼)
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
    );
  }
}
