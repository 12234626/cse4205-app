import 'package:flutter/material.dart';
import 'constants.dart';
import 'guideline_detail_page.dart';
import 'models/guideline_post_model.dart';
import 'carbon_survey_page.dart';
import 'guidelines.dart';
import 'community_page.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/tmplogo.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사용자 정보 카드
              Card(
                elevation: 8,
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
                    builder: (context) => GuidelineDetailPage(
                      post: GuidelinePost(
                        id: '1',
                        category: '일일퀘스트',
                        title: '분리수거 가이드라인',
                        content: '테스트 내용입니다.',
                        date: '2025-11-21',
                        imageUrl:
                            'https://plus.unsplash.com/premium_photo-1681987448179-4a93b7975018?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              _buildMenuButton(context, '개인설정', Icons.person_outline, () {}),
              const SizedBox(height: 8),
              _buildMenuButton(context, '특강 안내', Icons.school, () {}),
              const SizedBox(height: 24),

              // 탄소중립 레벨 측정 섹션
              const Text(
                '내 실천 레벨',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildCarbonSurveyButton(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.appBarGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/images/logowithtext.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'CO2Day',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text(
                '일일퀘스트 가이드라인 게시판',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuidelinesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.forum),
              title: const Text('커뮤니티 게시판', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestCard(String title, String? points) {
    return Card(
      elevation: 6,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.questCardGradient,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              const Icon(Icons.attach_file, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (points != null)
                ElevatedButton(
                  onPressed: () {
                    // 퀘스트 완료 처리
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    points,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
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
      elevation: 4,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildCarbonSurveyButton(BuildContext context) {
    return Card(
      elevation: 6,
      color: Color.fromRGBO(129, 199, 132, 0.3),
      child: ListTile(
        leading: Icon(Icons.eco, color: AppColors.primary, size: 32),
        title: const Text(
          '탄소중립 실천 레벨 측정하기',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('나의 탄소중립 실천도를 확인해보세요'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CarbonSurveyPage()),
          );
        },
      ),
    );
  }
}
