import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../common/constants.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class SignupStepPage extends StatefulWidget {
  final String? provider;

  const SignupStepPage({super.key, this.provider});

  @override
  State<SignupStepPage> createState() => _SignupStepPageState();
}

class _SignupStepPageState extends State<SignupStepPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // 폼 데이터
  DateTime? _birthDate;
  String _selectedRole = 'MENTEE'; // 기본값: MENTEE (학생)

  // 닉네임 관련
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNicknameChecked = false;
  bool _isNicknameAvailable = false;
  String? _nicknameErrorMessage;

  // 멘토 닉네임 관련
  final TextEditingController _mentorNicknameController =
      TextEditingController();
  String? _mentorNickname;
  String? _mentorNicknameErrorMessage;
  bool _isMentorNicknameValid = false;

  // 생년월일 관련
  final TextEditingController _birthDateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _mentorNicknameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      setState(() {
        _nicknameErrorMessage = '닉네임을 입력해주세요.';
        _isNicknameChecked = false;
        _isNicknameAvailable = false;
      });
      return;
    }

    // 닉네임 형식 검증 (한글, 영어, 숫자만)
    final validPattern = RegExp(r'^[가-힣a-zA-Z0-9]+$');
    if (!validPattern.hasMatch(nickname)) {
      setState(() {
        _nicknameErrorMessage = '닉네임은 한글, 영어, 숫자만 사용할 수 있습니다.';
        _isNicknameChecked = false;
        _isNicknameAvailable = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get(
        '/api/user/profile/username/$nickname',
      );

      bool isAvailable = true;
      if (response.success) {
        isAvailable = false;
      }

      setState(() {
        _isNicknameChecked = true;
        _isNicknameAvailable = isAvailable;
        _isLoading = false;

        if (!isAvailable) {
          _nicknameErrorMessage = '이미 사용 중인 닉네임입니다. 다른 닉네임을 입력해주세요.';
        } else {
          _nicknameErrorMessage = null;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _nicknameErrorMessage = '닉네임 중복 확인 중 오류가 발생했습니다.';
        _isNicknameChecked = false;
        _isNicknameAvailable = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('중복 확인 실패: ${e.toString()}')));
      }
    }
  }

  Future<void> _validateAndProceed() async {
    final mentorNickname = _mentorNicknameController.text.trim();

    if (mentorNickname.isEmpty) {
      _nextStep();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 닉네임으로 사용자 프로필 조회
      final response = await ApiService.get(
        '/api/user/profile/username/$mentorNickname',
      );

      if (!mounted) return;

      if (!response.success || response.data == null) {
        setState(() {
          _mentorNicknameErrorMessage = '해당 닉네임의 사용자를 찾을 수 없습니다.';
          _isMentorNicknameValid = false;
          _mentorNickname = null;
          _isLoading = false;
        });
        return;
      }

      // 멘토 정보 추출
      final userData = response.data;
      final userRole = userData['role'];

      if (userRole == null) {
        setState(() {
          _mentorNicknameErrorMessage = '사용자 정보를 가져올 수 없습니다.';
          _isMentorNicknameValid = false;
          _mentorNickname = null;
          _isLoading = false;
        });
        return;
      }

      // 멘토 역할 확인
      if (userRole != 'MENTOR') {
        setState(() {
          _mentorNicknameErrorMessage = '해당 사용자는 멘토가 아닙니다.';
          _isMentorNicknameValid = false;
          _mentorNickname = null;
          _isLoading = false;
        });
        return;
      }

      // 멘토 유효성 확인 완료
      setState(() {
        _mentorNicknameErrorMessage = null;
        _isMentorNicknameValid = true;
        _mentorNickname = mentorNickname;
        _selectedRole = 'MENTEE'; // 멘토를 입력한 경우 자동으로 MENTEE로 설정
        _isLoading = false;
      });

      // 검증 성공 시 다음 단계로
      _nextStep();
    } catch (e) {
      if (mounted) {
        setState(() {
          _mentorNicknameErrorMessage = '멘토 확인 중 오류가 발생했습니다.';
          _isMentorNicknameValid = false;
          _mentorNickname = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectBirthDate() async {
    // 기본 날짜: 이미 선택된 날짜가 있으면 그 날짜, 없으면 현재 날짜
    final DateTime initialDate = _birthDate ?? DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _completeSignup() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty || !_isNicknameAvailable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임을 확인해주세요.')));
      return;
    }

    if (widget.provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('잘못된 접근입니다. 소셜 로그인 후 다시 시도해주세요.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 백엔드 API 호출하여 PostgreSQL DB에 저장
      await AuthService.register(widget.provider!, nickname, _selectedRole);

      if (!mounted) return;

      // 멘토 닉네임을 입력했고 유효한 경우, 멘토 요청 전송
      if (_mentorNickname != null && _isMentorNicknameValid) {
        try {
          final requestResponse = await ApiService.post(
            '/api/user/mentor-request',
            body: {'otherUsername': _mentorNickname},
          );

          if (!mounted) return;

          if (requestResponse.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('회원가입이 완료되었고 멘토 요청이 전송되었습니다!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('회원가입은 완료되었으나 멘토 요청 전송에 실패했습니다.')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('회원가입은 완료되었으나 멘토 요청 전송 중 오류가 발생했습니다.'),
              ),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다!')));
      }

      // 로비로 이동
      Navigator.pushNamedAndRemoveUntil(context, '/lobby', (route) => false);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('회원가입 실패: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        title: const Text('회원가입'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 진행 상황 표시
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 4,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentStep + 1}/4',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNicknameStep(),
                  _buildBirthDateStep(),
                  _buildParentAccountStep(),
                  _buildRoleStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '닉네임을 입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '한글, 영어, 숫자만 사용할 수 있습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: '닉네임',
              hintText: '닉네임을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: _isNicknameChecked && _isNicknameAvailable
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[가-힣a-zA-Z0-9]')),
            ],
            onChanged: (value) {
              setState(() {
                _isNicknameChecked = false;
                _isNicknameAvailable = false;
                _nicknameErrorMessage = null;
              });
            },
          ),
          if (_nicknameErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _nicknameErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _checkNicknameDuplicate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '중복 체크',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isNicknameAvailable ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '생년월일을 입력해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '정확한 생년월일을 입력해주세요',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _birthDateController,
            decoration: InputDecoration(
              labelText: '생년월일',
              hintText: 'YYYY-MM-DD',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _selectBirthDate,
              ),
            ),
            readOnly: true,
            onTap: _selectBirthDate,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _birthDate != null ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentAccountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '멘토 계정 정보',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '만 14세 이하는 멘토 계정 연결을 권장합니다 (선택사항)',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _mentorNicknameController,
            decoration: InputDecoration(
              labelText: '멘토 닉네임',
              hintText: '멘토 닉네임을 입력하세요',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: _isMentorNicknameValid
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[가-힣a-zA-Z0-9]')),
            ],
            onChanged: (value) {
              // 입력 시 에러 메시지와 검증 상태 초기화
              setState(() {
                _mentorNicknameErrorMessage = null;
                _isMentorNicknameValid = false;
                _mentorNickname = null;
              });
            },
          ),
          if (_mentorNicknameErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _mentorNicknameErrorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          if (_isMentorNicknameValid)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '유효한 멘토입니다.',
                style: TextStyle(color: AppColors.primary, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_isMentorNicknameValid ||
                        _mentorNicknameController.text.trim().isEmpty)
                  ? _nextStep
                  : _validateAndProceed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                '다음',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      // 건너뛰기: 멘토 정보 초기화 후 다음 단계로
                      setState(() {
                        _mentorNicknameController.clear();
                        _mentorNicknameErrorMessage = null;
                        _isMentorNicknameValid = false;
                        _mentorNickname = null;
                      });
                      _nextStep();
                    },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                '건너뛰기',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '역할을 선택해주세요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '사용 목적에 맞는 역할을 선택하세요',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // mentee (학생) 선택
          InkWell(
            onTap: _mentorNickname != null
                ? null
                : () => setState(() => _selectedRole = 'MENTEE'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedRole == 'MENTEE'
                      ? AppColors.primary
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
                color: _selectedRole == 'MENTEE'
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school,
                    size: 40,
                    color: _selectedRole == 'MENTEE'
                        ? AppColors.primary
                        : Colors.grey[600],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '멘티',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _selectedRole == 'MENTEE'
                                ? AppColors.primary
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '학습을 위해 사용합니다',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_selectedRole == 'MENTEE')
                    Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // mentor (학부모/멘토) 선택
          Opacity(
            opacity: _mentorNickname != null ? 0.5 : 1.0,
            child: InkWell(
              onTap: _mentorNickname != null
                  ? null
                  : () => setState(() => _selectedRole = 'MENTOR'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedRole == 'MENTOR'
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: _selectedRole == 'MENTOR'
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.family_restroom,
                      size: 40,
                      color: _selectedRole == 'MENTOR'
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '멘토',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _selectedRole == 'MENTOR'
                                  ? AppColors.primary
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '멘티의 학습을 관리합니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedRole == 'MENTOR')
                      Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
          if (_mentorNickname != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '멘토를 입력하셨기 때문에 멘티 역할로 자동 설정됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _completeSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '회원가입 완료',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
