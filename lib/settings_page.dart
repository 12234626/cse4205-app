import 'package:flutter/material.dart';
import 'constants.dart';
import 'services/api_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _dailyQuestNotification = true;
  bool _weeklyQuestNotification = false;
  String _username = '사용자';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.get('/api/user/profile');

      if (response.success && response.data != null) {
        setState(() {
          _username = response.data['username'] ?? '사용자';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                ); // 로그인 페이지로 이동
              },
              child: const Text('예'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 정보 섹션
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // 프로필 사진
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: const NetworkImage(
                        'https://plus.unsplash.com/premium_photo-1686750875748-d00684d36b1e?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ),
                      onBackgroundImageError: (exception, stackTrace) {
                        // 이미지 로드 실패 처리
                      },
                      child: Container(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 유저 닉네임
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Text(
                            _username,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // 개인정보 수정 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    // 개인정보 수정 페이지로 이동
                  },
                  child: const Text(
                    '계정 정보 수정',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
            const SizedBox(height: 8),

            // 알림 설정 섹션
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 12.0,
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Text(
                    '알림',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // 일일퀘스트 알림
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('일일퀘스트 알림', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _dailyQuestNotification,
                    onChanged: (value) {
                      setState(() {
                        _dailyQuestNotification = value;
                      });
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            // 주간퀘스트 알림
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('주간퀘스트 알림', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: _weeklyQuestNotification,
                    onChanged: (value) {
                      setState(() {
                        _weeklyQuestNotification = value;
                      });
                    },
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(thickness: 1),

            // 로그아웃 버튼
            ListTile(
              leading: Icon(Icons.logout, color: Colors.grey[700]),
              title: const Text('로그아웃', style: TextStyle(fontSize: 16)),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }
}
