import 'package:flutter/material.dart';
import 'constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  // 임시 데이터 (추후 데이터베이스에서 가져올 예정)
  final int currentPoints = 70;
  final int maxPoints = 100;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
          children: [
            // 프로필 섹션
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 16),
            const Text(
              '닉네임',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // 닉네임 변경
              },
              child: const Text('< 닉네임 변경 >'),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            // 통계 섹션 (연속 해결 및 점수)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(Icons.access_time, 'N일 연속 해결!'),
                _buildStatItem(Icons.emoji_events, '35135점'),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),

            // 일일 퀘스트 달성도 섹션
            const Text(
              '오늘의 일일 퀘스트 달성도',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressBar(),
            const SizedBox(height: 8),
            Text(
              '$currentPoints / $maxPoints 포인트',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentPoints / maxPoints;
    const segmentCount = 5; // 20단위로 5개 구간

    return Container(
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            // 배경 (빈 부분)
            Container(color: AppColors.progressBarBackground),

            // 진행 바 (그라데이션 + 애니메이션)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.progressBarFill,
                          AppColors.progressBarFill.withValues(alpha: 0.7),
                          AppColors.progressBarFill,
                        ],
                        stops: [
                          _animation.value - 0.3,
                          _animation.value,
                          _animation.value + 0.3,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // 구분선 (20단위로 표시)
            Row(
              children: List.generate(
                segmentCount - 1,
                (index) => Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Container(width: 2, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
