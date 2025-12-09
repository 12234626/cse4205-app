import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'dart:async';
import '../../common/constants.dart';
import '../survey/carbon_survey_page.dart';
import '../guide/guidelines.dart';
import '../community/community_page.dart';
import '../community/community_write_page.dart';
import '../../services/api_service.dart';
import '../mentor/mentor_request_page.dart';
import '../mentor/mentor_request_management_page.dart';
import '../mentor/remove_mentor_page.dart';
import '../mentor/remove_mentee_page.dart';
import '../profile/profile_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> with TickerProviderStateMixin {
  String _username = '사용자';
  int _streak = 0;
  int _level = 1;
  String _role = 'MENTEE';
  List<Map<String, dynamic>> _mentees = [];
  Map<String, dynamic>? _mentor;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dailyQuests = [];
  bool _isLoadingQuests = false;
  Set<int> _questsReadyForAuth = {}; // 인증 버튼 상태로 변경된 퀘스트 ID들
  Map<int, Timer?> _authButtonTimers = {}; // 각 퀘스트별 타이머

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadDailyQuests();

    // 파도 애니메이션 (6초)
    _waveController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // 애니메이션 시퀀스 시작
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    while (mounted) {
      // 파도 애니메이션 실행
      await _waveController.forward();
      _waveController.reset();

      await Future.delayed(const Duration(seconds: 6));
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    // 모든 타이머 취소
    for (var timer in _authButtonTimers.values) {
      timer?.cancel();
    }
    _authButtonTimers.clear();
    super.dispose();
  }

  Future<void> _loadDailyQuests() async {
    setState(() => _isLoadingQuests = true);

    try {
      final response = await ApiService.post('/api/user-quest/daily/assign');

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _dailyQuests = (response.data as List)
                .map((userQuest) {
                  // quest 객체가 있는지 확인하고 안전하게 파싱
                  final quest = userQuest['quest'];

                  if (quest == null) {
                    return null;
                  }

                  return {
                    'userQuestId': userQuest['userQuestId'],
                    'questId': quest['questId'],
                    'title': quest['title'] ?? '퀘스트',
                    'expReward': quest['expReward'] ?? 0,
                    'status': userQuest['status'] ?? 'PENDING',
                    'completedAt': userQuest['completedAt'],
                  };
                })
                .where((quest) => quest != null)
                .cast<Map<String, dynamic>>()
                .toList();

            // 퀘스트 정렬: 출석을 맨 앞으로
            _dailyQuests.sort((a, b) {
              final titleA = a['title'] as String;
              final titleB = b['title'] as String;

              // 출석이 최우선
              if (titleA.contains('출석')) return -1;
              if (titleB.contains('출석')) return 1;

              // 나머지는 원래 순서 유지
              return 0;
            });

            _isLoadingQuests = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingQuests = false);

          // 에러 메시지를 더 구체적으로 표시
          final errorMsg =
              response.message?.toString() ??
              response.error?.toString() ??
              '퀘스트 정보를 불러오지 못했습니다.';

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('퀘스트 로딩 실패: $errorMsg')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingQuests = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('퀘스트 로딩 오류: ${e.toString()}')));
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.get('/api/user/profile');

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _username = response.data['username'] ?? '사용자';
            _streak = response.data['streak'] ?? 0;
            _level = response.data['level'] ?? 1;
            _role = response.data['role'] ?? 'MENTEE';
            _isLoading = false;
          });

          // 멘토인 경우 별도로 멘티 목록 조회
          if (_role == 'MENTOR') {
            _loadMentees();
          } else if (_role == 'MENTEE') {
            _loadMentor();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('프로필 정보를 불러오지 못했습니다.')));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
    }
  }

  Future<void> _loadMentees() async {
    try {
      final response = await ApiService.get('/api/user/mentee');

      if (response.success && response.data != null) {
        if (mounted) {
          // response.data가 List인지 확인
          final dataList = response.data is List ? response.data as List : [];

          setState(() {
            _mentees = List<Map<String, dynamic>>.from(
              dataList.map(
                (mentee) => {
                  'userId': mentee['userId'] ?? mentee['id'],
                  'username': mentee['username'] ?? '멘티',
                  'streak': mentee['streak'] ?? 0,
                  'level': mentee['level'] ?? 1,
                  'exp': mentee['exp'] ?? 0,
                },
              ),
            );
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('멘티 목록 조회 오류: ${e.toString()}')));
      }
    }
  }

  Future<void> _loadMentor() async {
    try {
      final response = await ApiService.get('/api/user/mentor');

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _mentor = {
              'userId': response.data['userId'] ?? response.data['id'],
              'username': response.data['username'] ?? '멘토',
              'streak': response.data['streak'] ?? 0,
              'level': response.data['level'] ?? 1,
              'exp': response.data['exp'] ?? 0,
            };
          });
        } else {
          // 멘토가 없는 경우 null로 설정
          setState(() {
            _mentor = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // 에러 발생 시 멘토를 null로 설정 (삭제된 경우 등)
        setState(() {
          _mentor = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('멘토 정보 조회 오류: ${e.toString()}')));
      }
    }
  }

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
        title: AnimatedBuilder(
          animation: _waveAnimation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedLetter('C', 0),
                _buildAnimatedLetter('O', 1),
                _buildAnimatedSubscript('2'),
                _buildAnimatedLetter('D', 2),
                _buildAnimatedLetter('a', 3),
                _buildAnimatedLetter('y', 4),
              ],
            );
          },
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF1F8E9), // 매우 연한 연두
                          const Color(0xFFFFF9C4), // 매우 연한 노랑
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue[400],
                                child: const Icon(
                                  Icons.person,
                                  size: 45,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 레벨
                                    Text(
                                      'Lv. $_level',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // 사용자 닉네임
                                    Text(
                                      _username,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // 스트릭 정보
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department,
                                            color: Colors.deepOrange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$_streak일 연속 달성!',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 오른쪽 레벨 아이콘 (큰 버전)
                              Icon(
                                _getLevelIcon(_level),
                                color: _getLevelColor(
                                  _level,
                                ).withValues(alpha: 0.3),
                                size: 50,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 멘토인 경우 멘티 목록 표시
              if (_role == 'MENTOR') ..._buildMenteeSection(),

              // 멘티인 경우 멘토 정보 표시
              if (_role == 'MENTEE') ..._buildMentorSection(),

              // 일일 퀘스트 섹션
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '일일 퀘스트',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadDailyQuests,
                    tooltip: '퀘스트 새로고침',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoadingQuests)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_dailyQuests.isEmpty)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '오늘의 퀘스트를 불러올 수 없습니다.',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ),
                )
              else
                ..._dailyQuests.map((quest) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildQuestCard(
                      quest['title'],
                      '+${quest['expReward']}',
                      userQuestId: quest['userQuestId'],
                      isCompleted: quest['status'] == 'COMPLETED',
                      isReadyForAuth: _questsReadyForAuth.contains(quest['userQuestId']),
                    ),
                  );
                }),
              const SizedBox(height: 24),

              // 하단 메뉴

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
              title: const Text('인증 게시판', style: TextStyle(fontSize: 16)),
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
            // 역할별 메뉴 항목
            if (_role == 'MENTEE') ...[
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('멘토 요청 보내기', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MentorRequestPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_remove),
                title: const Text('멘토 삭제', style: TextStyle(fontSize: 16)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RemoveMentorPage(),
                    ),
                  );
                  // 멘토 삭제 후 돌아왔을 때 멘토 정보 새로고침
                  if (result == true) {
                    _loadMentor();
                  }
                },
              ),
            ],
            if (_role == 'MENTOR') ...[
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text(
                  '받은 멘토 요청 관리',
                  style: TextStyle(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MentorRequestManagementPage(),
                    ),
                  );
                  // 요청 수락 후 돌아왔을 때 멘티 목록 새로고침
                  if (result == true) {
                    _loadMentees();
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_alt_outlined),
                title: const Text('멘티 삭제', style: TextStyle(fontSize: 16)),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RemoveMenteePage(),
                    ),
                  );
                  // 멘티 삭제 후 돌아왔을 때 멘티 목록 새로고침
                  if (result == true) {
                    _loadMentees();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 애니메이션이 적용된 글자 위젯
  Widget _buildAnimatedLetter(String letter, int index) {
    // 파도 애니메이션: 위아래로 미세하게 움직임
    final offset =
        math.sin((_waveAnimation.value * 2 * math.pi) + (index * math.pi / 5)) *
        2;

    return Transform.translate(
      offset: Offset(0, offset),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.white, Color(0xFFE0F7FA)],
        ).createShader(bounds),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // CO2의 2를 작게 표시
  Widget _buildAnimatedSubscript(String letter) {
    // 파도 애니메이션
    final offset =
        math.sin((_waveAnimation.value * 2 * math.pi) + (1.5 * math.pi / 5)) *
        2;

    return Transform.translate(
      offset: Offset(0, offset + 8),
      child: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.white, Color(0xFFE0F7FA)],
        ).createShader(bounds),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 레벨에 따른 아이콘 반환
  IconData _getLevelIcon(int level) {
    if (level >= 25) {
      return Icons.emoji_events; // 트로피 (25-30)
    } else if (level >= 20) {
      return Icons.workspace_premium; // 프리미엄 배지 (20-24)
    } else if (level >= 15) {
      return Icons.military_tech; // 메달 (15-19)
    } else if (level >= 10) {
      return Icons.shield; // 실드 (10-14)
    } else if (level >= 5) {
      return Icons.star; // 별 (5-9)
    } else {
      return Icons.stars; // 작은 별들 (1-4)
    }
  }

  // 레벨에 따른 색상 반환
  Color _getLevelColor(int level) {
    if (level >= 25) {
      return const Color(0xFFFFD700); // 금색 (25-30)
    } else if (level >= 20) {
      return const Color(0xFFE6E6FA); // 라벤더 (20-24)
    } else if (level >= 15) {
      return const Color(0xFFFFA500); // 오렌지 (15-19)
    } else if (level >= 10) {
      return const Color(0xFF4169E1); // 로얄블루 (10-14)
    } else if (level >= 5) {
      return Colors.amber; // 호박색 (5-9)
    } else {
      return Colors.grey[600]!; // 회색 (1-4)
    }
  }

  // 퀘스트 제목에 따라 적절한 아이콘 반환
  IconData _getQuestIcon(String title) {
    if (title.contains('출석')) {
      return Icons.check_circle; // 출석 체크
    } else if (title.contains('인증') ||
        title.contains('게시글') ||
        title.contains('확인')) {
      return Icons.thumb_up; // 따봉 (인증/검증)
    } else if (title.contains('분리수거')) {
      return Icons.recycling; // 재활용
    } else if (title.contains('도보') ||
        title.contains('자전거') ||
        title.contains('대중교통')) {
      return Icons.directions_walk; // 이동
    } else if (title.contains('대기전력') || title.contains('전력')) {
      return Icons.power_off; // 전력
    } else if (title.contains('텀블러') || title.contains('컵')) {
      return Icons.coffee; // 텀블러/컵
    } else if (title.contains('음식물') || title.contains('남기지')) {
      return Icons.restaurant; // 음식
    } else if (title.contains('세탁')) {
      return Icons.local_laundry_service; // 세탁
    } else {
      return Icons.eco; // 기본 친환경 아이콘
    }
  }

  Widget _buildQuestCard(
    String title,
    String? points, {
    required int userQuestId,
    bool isCompleted = false,
    bool isReadyForAuth = false,
  }) {
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
              Icon(_getQuestIcon(title), color: Colors.green[700], size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: title.length > 15 ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (points != null)
                isCompleted
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '완료',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                        child: ElevatedButton(
                          key: ValueKey<bool>(isReadyForAuth),
                          onPressed: () async {
                            if (isReadyForAuth) {
                              // 기존 타이머 취소
                              _authButtonTimers[userQuestId]?.cancel();
                              _authButtonTimers.remove(userQuestId);
                              
                              // 인증 버튼 클릭 시 글 작성 페이지로 이동
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommunityWritePage(
                                    userQuestId: userQuestId,
                                  ),
                                ),
                              );
                              
                              // 게시글 작성 완료 또는 취소 시 인증 버튼 상태 초기화
                              if (mounted) {
                                setState(() {
                                  _questsReadyForAuth.remove(userQuestId);
                                });
                                // 게시글 작성 완료 시 퀘스트 목록 새로고침
                                if (result == true) {
                                  _loadDailyQuests();
                                }
                              }
                            } else {
                              // 점수 버튼 클릭 시 인증 버튼으로 변경
                              setState(() {
                                _questsReadyForAuth.add(userQuestId);
                              });
                              
                              // 6초 후 자동으로 점수 버튼으로 복귀
                              _authButtonTimers[userQuestId]?.cancel();
                              _authButtonTimers[userQuestId] = Timer(
                                const Duration(seconds: 6),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _questsReadyForAuth.remove(userQuestId);
                                    });
                                  }
                                  _authButtonTimers.remove(userQuestId);
                                },
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 6,
                            shadowColor: const Color.fromRGBO(0, 0, 0, 0.4),
                            backgroundColor: isReadyForAuth 
                                ? Colors.green[50] 
                                : null,
                            foregroundColor: isReadyForAuth 
                                ? Colors.orange[700] 
                                : null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            isReadyForAuth ? '인증' : points,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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

  List<Widget> _buildMenteeSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '관리 중인 멘티',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMentees,
            tooltip: '새로고침',
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (_mentees.isEmpty)
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '현재 관리 중인 멘티가 없습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
        )
      else
        ..._mentees.map(
          (mentee) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildMenteeCard(
              mentee['username'],
              mentee['streak'],
              mentee['level'],
              mentee['exp'],
            ),
          ),
        ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildMenteeCard(String username, int streak, int level, int exp) {
    return Card(
      elevation: 4,
      color: const Color(0xFFE8F5E9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(username: username),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 25,
                child: Icon(Icons.person, size: 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text('$streak일'),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Lv.$level'),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text('EXP $exp'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMentorSection() {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '나의 멘토',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMentor,
            tooltip: '새로고침',
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (_mentor == null)
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '아직 멘토가 지정되지 않았습니다.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ),
        )
      else
        _buildMentorCard(
          _mentor!['username'],
          _mentor!['streak'],
          _mentor!['level'],
          _mentor!['exp'],
        ),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildMentorCard(String username, int streak, int level, int exp) {
    return Card(
      elevation: 4,
      color: const Color(0xFFFFF3E0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(username: username),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text('$streak일'),
                      const SizedBox(width: 16),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('Lv.$level'),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text('EXP $exp'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
