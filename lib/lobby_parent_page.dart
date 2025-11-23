import 'package:flutter/material.dart';
import 'constants.dart';

class LobbyParentPage extends StatelessWidget {
  const LobbyParentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, '/lobby-parent');
              },
              child: Image.asset(
                'assets/images/tmplogo.png',
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
                              '보호자님 안녕하세요!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('아이 관리 대시보드'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '아이 목록',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChildCard('아이이름 1', '9,221,372,036,854,775,808개 목표 달성', true),
            const SizedBox(height: 8),
            _buildChildCard('아이이름 2', null, false),
            const SizedBox(height: 8),
            _buildChildCard('아이이름 3', null, false),
            const SizedBox(height: 24),
            const Text(
              '캐러셀 / 돌판 구리',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny, size: 60, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      '캐러셀 아이템 1',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(String name, String? achievement, bool hasToggle) {
    return Card(
      color: const Color(0xFFE8D5F2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.child_care)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (achievement != null) ...[
                    const SizedBox(height: 4),
                    Text(achievement, style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (hasToggle) Switch(value: true, onChanged: (value) {}),
          ],
        ),
      ),
    );
  }
}
