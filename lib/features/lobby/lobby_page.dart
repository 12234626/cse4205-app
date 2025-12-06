import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../guide/guideline_detail_page.dart';
import '../../models/guideline_post_model.dart';
import '../survey/carbon_survey_page.dart';
import '../guide/guidelines.dart';
import '../community/community_page.dart';
import '../../services/api_service.dart';
import '../mentor/mentor_request_page.dart';
import '../mentor/mentor_request_management_page.dart';
import '../profile/profile_page.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  String _username = '사용자';
  int _streak = 0;
  int _level = 1;
  String _role = 'mentee';
  List<Map<String, dynamic>> _mentees = [];
  Map<String, dynamic>? _mentor;
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
        if (mounted) {
          setState(() {
            _username = response.data['username'] ?? '사용자';
            _streak = response.data['streak'] ?? 0;
            _level = response.data['level'] ?? 1;
            _role = response.data['role'] ?? 'mentee';
            _isLoading = false;
          });

          // 멘토인 경우 별도로 멘티 목록 조회
          if (_role == 'mentor') {
            _loadMentees();
          } else if (_role == 'mentee') {
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
          setState(() {
            _mentees = List<Map<String, dynamic>>.from(
              response.data.map(
                (mentee) => {
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

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _mentor = {
              'username': response.data['username'] ?? '멘토',
              'streak': response.data['streak'] ?? 0,
              'level': response.data['level'] ?? 1,
              'exp': response.data['exp'] ?? 0,
            };
          });
        }
      }
    } catch (e) {
      if (mounted) {
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
                          child: _isLoading
                              ? const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '안녕 $_username!',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('$_streak일 연속 해결!'),
                                        const SizedBox(width: 16),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 4),
                                        Text('레벨 $_level'),
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

              // 멘토인 경우 멘티 목록 표시
              if (_role == 'mentor') ..._buildMenteeSection(),

              // 멘티인 경우 멘토 정보 표시
              if (_role == 'mentee') ..._buildMentorSection(),

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
            // 역할별 메뉴 항목
            if (_role == 'mentee')
              ListTile(
                leading: const Icon(Icons.person_add),
                title: const Text('멘토 추가', style: TextStyle(fontSize: 16)),
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
            if (_role == 'mentor')
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('멘토 요청 관리', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MentorRequestManagementPage(),
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
