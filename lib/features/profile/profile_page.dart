import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../common/constants.dart';
import '../../services/api_service.dart';

// 식물 성장 단계
enum PlantStage { sprout, sapling, tree }

// 떨어지는 나뭇잎 클래스
class FallingLeaf {
  final double x; // 0.0 ~ 1.0 (화면 너비 비율)
  final double rotation; // 초기 회전 각도
  final double speed; // 떨어지는 속도
  final double swayAmount; // 좌우 흔들림 정도

  FallingLeaf()
    : x = math.Random().nextDouble(),
      rotation = math.Random().nextDouble() * math.pi * 2,
      speed = 0.8 + math.Random().nextDouble() * 0.4,
      swayAmount = 0.05 + math.Random().nextDouble() * 0.1;
}

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // 애니메이션 컨트롤러들
  late AnimationController _expBarController;

  // 사용자 정보
  String _username = '사용자';
  int _streak = 0;
  int _level = 0;
  int _currentExp = 0;
  int _nextLevelExp = 100;
  bool _isLoading = true;

  // 일일 퀘스트 정보
  int _completedDailyQuests = 0;
  int _totalDailyQuests = 4;

  // 나뭇잎 애니메이션
  final List<FallingLeaf> _fallingLeaves = [];
  Timer? _leafSpawnTimer;

  @override
  void initState() {
    super.initState();

    // ...existing code...

    // 경험치 바 애니메이션 (미용실 간판 효과)
    _expBarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _loadUserProfile();
    _loadDailyQuestProgress();
  }

  Future<void> _loadUserProfile() async {
    try {
      final endpoint = widget.username != null
          ? '/api/user/profile/username/${widget.username}'
          // 현재 사용자 프로필
          : '/api/user/profile';

      final response = await ApiService.get(endpoint);

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _username = response.data['username'] ?? '사용자';
            _streak = response.data['streak'] ?? 0;

            final expValue = response.data['exp'] ?? 0;
            final int exp = expValue is int
                ? expValue
                : (expValue as num).toInt();

            _level = exp ~/ 100;
            _currentExp = exp % 100;
            _nextLevelExp = 100 - (exp % 100);
            _isLoading = false;
          });

          // 나무 단계일 때만 나뭇잎 생성 시작
          if (_getPlantStage() == PlantStage.tree) {
            _startLeafSpawning();
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('프로필 로딩 에러: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDailyQuestProgress() async {
    try {
      // 서버에서 매일 06시에 자동으로 퀘스트 할당, 클라이언트는 조회만
      final response = await ApiService.get('/api/user-quest/daily/today');

      if (response.success && response.data != null) {
        if (mounted) {
          final quests = (response.data as List);
          // COMPLETED 또는 CONSENTED 상태 모두 완료로 처리
          final completed = quests.where((q) {
            final status = q['status'];
            return status == 'COMPLETED' || status == 'CONSENTED';
          }).length;

          debugPrint('일일 퀘스트 진척도: $completed / ${quests.length}');

          setState(() {
            _completedDailyQuests = completed;
            _totalDailyQuests = quests.length;
          });
        }
      }
    } catch (e) {
      // 에러 시 기본값 유지
      debugPrint('일일 퀘스트 로딩 에러: $e');
    }
  }

  void _startLeafSpawning() {
    _leafSpawnTimer?.cancel();
    _leafSpawnTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      if (_fallingLeaves.length < 10) {
        setState(() {
          _fallingLeaves.add(FallingLeaf());
        });

        // 5초 후 나뭇잎 제거
        Future.delayed(const Duration(seconds: 5), () {
          if (!mounted) return;
          if (_fallingLeaves.isNotEmpty) {
            setState(() {
              _fallingLeaves.removeAt(0);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // ...existing code...
    _expBarController.dispose();
    _leafSpawnTimer?.cancel();
    super.dispose();
  }

  String _getPlantImagePath(PlantStage stage) {
    switch (stage) {
      case PlantStage.sprout:
        return 'assets/images/saessak.png';
      case PlantStage.sapling:
        return 'assets/images/sapling.png';
      case PlantStage.tree:
        return 'assets/images/tree.png';
    }
  }

  PlantStage _getPlantStage() {
    if (_streak <= 3) {
      return PlantStage.sprout;
    } else if (_streak <= 7) {
      return PlantStage.sapling;
    } else {
      return PlantStage.tree;
    }
  }

  double _getPlantSize() {
    final stage = _getPlantStage();
    final cappedStreak = _streak > 30 ? 30 : _streak; // 30일 상한선

    switch (stage) {
      case PlantStage.sprout:
        // 1일: 0.28, 2일: 0.48, 3일: 0.68 (기본값을 더 키움)
        return 0.28 + (cappedStreak * 0.2);
      case PlantStage.sapling:
        // 4일: 0.55, 5일: 0.7, 6일: 0.85, 7일: 1.0 (대략)
        return 0.25 + ((cappedStreak - 3) * 0.15);
      case PlantStage.tree:
        // 8일: 1.05, 30일: 1.93
        return 0.65 + ((cappedStreak - 7) * 0.04);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('프로필'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 식물 + 땅 영역
            _buildPlantSection(),

            // 프로필 정보 영역
            _buildProfileInfoSection(),

            // 경험치 바
            _buildExpBar(),

            const SizedBox(height: 24),

            // 일일 퀘스트 진행도
            _buildDailyQuestProgress(),

            const SizedBox(height: 24),

            // 테마 선택
            _buildThemeSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 하늘은 온전히 채우고, 땅의 아랫부분만 흰색으로 페이드되는 버전
  Widget _buildPlantSection() {
    final plantSize = _getPlantSize();
    final stage = _getPlantStage();

    return SizedBox(
      height: 390,
      width: double.infinity,
      child: Stack(
        children: [
          // 1) 하늘 배경: 전체 영역 하늘색으로 덮기
          Container(
            height: 390,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFE1F5FE), // 밝은 하늘색 (위)
                  Color(0xFF81D4FA), // 조금 더 진한 하늘색 (아래)
                ],
              ),
            ),
          ),

          // 2) 땅 이미지: 하늘 위에 바로 올리기 (투명 영역 뒤에도 하늘이 보임)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ground.png',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // 3) 땅의 "아랫부분"만 흰색으로 페이드되는 오버레이
          //    위쪽은 투명이라 땅 윗부분은 하늘색과 자연스럽게 이어짐
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent, // 위: 완전 투명
                    Colors.transparent, // 중간까지 투명
                    Colors.white, // 아래: 흰색으로
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 나무 이미지 (바운스 애니메이션 적용)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                _getPlantImagePath(stage),
                height: 180 * plantSize,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 나뭇잎 이펙트 (나무 단계일 때만)
          if (stage == PlantStage.tree)
            ..._fallingLeaves.map((leaf) => _buildFallingLeaf(leaf)),
        ],
      ),
    );
  }

  /// 나뭇잎 위젯: Stack의 직접 자식은 Positioned
  Widget _buildFallingLeaf(FallingLeaf leaf) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          return TweenAnimationBuilder<double>(
            key: ValueKey(leaf),
            duration: const Duration(seconds: 5),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              final sway = math.sin(value * math.pi * 4) * leaf.swayAmount;

              final dx = (screenWidth * (leaf.x + sway)).clamp(
                0.0,
                screenWidth - 20,
              );

              final dy = 50 + (200 * value * leaf.speed);

              return Transform.translate(
                offset: Offset(dx.toDouble(), dy),
                child: Opacity(
                  opacity: (1.0 - (value * 0.5)).clamp(0.0, 1.0),
                  child: Transform.rotate(
                    angle: leaf.rotation + (value * math.pi * 2),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProfileInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 프로필 사진
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),

          const SizedBox(height: 16),

          // 레벨 + 닉네임
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Lv.$_level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpBar() {
    final progress = _currentExp / 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '경험치',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 경험치 바
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  // 진행 바 (기본 색상)
                  if (progress > 0)
                    FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 줄무늬 애니메이션 (분리된 레이어)
                  if (progress > 0)
                    AnimatedBuilder(
                      animation: _expBarController,
                      builder: (context, child) {
                        return FractionallySizedBox(
                          widthFactor: progress,
                          alignment: Alignment.centerLeft,
                          child: CustomPaint(
                            painter: StripePainter(
                              progress: _expBarController.value,
                            ),
                            size: const Size(double.infinity, 40),
                          ),
                        );
                      },
                    ),

                  // 경험치 텍스트
                  Center(
                    child: Text(
                      '$_currentExp / 100 EXP',
                      style: TextStyle(
                        color: progress > 0.3 ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        shadows: progress > 0.3
                            ? const [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black45,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '다음 레벨까지 $_nextLevelExp EXP',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuestProgress() {
    // 4개 중 2개만 완료하면 스트릭 증가 (오늘의 실천 완료)
    final isStreakComplete = _completedDailyQuests >= 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '오늘의 실천',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 진행도 바
          Row(
            children: List.generate(_totalDailyQuests, (index) {
              final isCompleted = index < _completedDailyQuests;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < _totalDailyQuests - 1 ? 8 : 0,
                  ),
                  height: 12,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // 완료 상태 표시
          if (isStreakComplete)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '오늘의 실천 완료!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              '$_completedDailyQuests / $_totalDailyQuests 완료 (2개 이상이면 스트릭 증가)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '테마 선택',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.palette, size: 30),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '기본 테마',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '현재 적용 중',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 경험치 바 스트라이프 효과
class StripePainter extends CustomPainter {
  final double progress;

  StripePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final stripeWidth = 20.0;
    final stripeSpacing = 30.0;
    final offset = progress * stripeSpacing;

    for (
      double x = -stripeSpacing + offset;
      x < size.width;
      x += stripeSpacing
    ) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth + size.height, size.height)
        ..lineTo(x + size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(StripePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
