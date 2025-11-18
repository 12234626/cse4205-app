import 'package:flutter/material.dart';
import 'constants.dart';
import 'guidelines.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // 메뉴 열기
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/lobby');
              },
              child: Image.asset(
                'assets/images/logo.png',
                height: 40,
                width: 40,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 사용자 정보 카드
            Card(
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(Icons.person, size: 35),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '안녕 김형주!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('1467일 연속 해결!'),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                const Text('별 개수'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 일일 퀘스트 섹션
            const Text(
              '일일 퀘스트',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildQuestCard('일일 출석하기', '+10'),
            const SizedBox(height: 8),
            _buildQuestCard('분리수거하기', '+30'),
            const SizedBox(height: 8),
            _buildQuestCard('목적지까지 걸어가기', '+20'),
            const SizedBox(height: 8),
            _buildQuestCard('소등하기', '+40'),
            const SizedBox(height: 24),

            // 하단 메뉴
            const Text(
              '일일퀘스트 가이드라인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMenuButton(context, '분리수거', Icons.assignment, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GuidelineDetailPage(
                    title: '가이드라인 : 분리수거',
                    content: '테스트 내용입니다.',
                    date: '2025-01-18',
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            _buildMenuButton(context, '개인설정', Icons.person_outline, () {}),
            const SizedBox(height: 8),
            _buildMenuButton(context, '특강 안내', Icons.school, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(String title, String? points) {
    return Card(
      color: AppColors.questCardBackground,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            const Icon(Icons.attach_file, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            if (points != null)
              ElevatedButton(
                onPressed: () {
                  // 퀘스트 완료 처리
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(points),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
