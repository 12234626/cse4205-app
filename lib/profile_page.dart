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
        child: Column(
          children: [
            // 배경 이미지와 프로필 사진 섹션
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // 배경 이미지
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Image.network(
                    'https://images.unsplash.com/photo-1502472584811-0a2f2feb8968?q=80&w=1740&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        child: const Center(
                          child: Icon(
                            Icons.image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 프로필 사진 (배경과 겹치게 배치)
                Positioned(
                  bottom: -50,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 60),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60), // 프로필 사진 공간 확보
            // 닉네임 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
