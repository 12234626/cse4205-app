import 'package:flutter/material.dart';
import 'constants.dart';

class OnboardingSurveyPage extends StatefulWidget {
  const OnboardingSurveyPage({super.key});

  @override
  State<OnboardingSurveyPage> createState() => _OnboardingSurveyPageState();
}

class _OnboardingSurveyPageState extends State<OnboardingSurveyPage> {
  int _currentStep = 0;

  // 설문 답변 저장
  String? _ageGroup;
  String? _occupation;
  final List<String> _interests = [];
  String? _environmentalConcern;
  String? _mainGoal;

  final List<String> _ageGroups = ['10대', '20대', '30대', '40대', '50대', '60대 이상'];

  final List<String> _occupations = ['학생', '직장인', '자영업', '주부', '무직', '기타'];

  final Map<String, String> _interestOptions = {
    'energy': '⚡ 에너지 절약',
    'transport': '🚗 친환경 이동',
    'food': '🍽️ 지속가능한 식습관',
    'waste': '♻️ 쓰레기 줄이기',
    'shopping': '🛍️ 친환경 소비',
    'learning': '📚 환경 지식 학습',
  };

  final List<String> _concernLevels = [
    '매우 걱정됨',
    '걱정됨',
    '보통',
    '별로 걱정 안 됨',
    '전혀 걱정 안 됨',
  ];

  final Map<String, String> _goals = {
    'learn': '환경 문제에 대해 배우고 싶어요',
    'practice': '실천 방법을 알고 싶어요',
    'habit': '좋은 습관을 만들고 싶어요',
    'track': '내 실천을 기록하고 싶어요',
    'community': '다른 사람들과 함께하고 싶어요',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('환영합니다! 🌱'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 진행 표시기
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: _buildCurrentStep(),
            ),
          ),

          // 하단 버튼
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(158, 158, 158, 0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: const Text('이전', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentStep == 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(
                      _currentStep < 4 ? '다음' : '완료',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildAgeStep();
      case 1:
        return _buildOccupationStep();
      case 2:
        return _buildInterestsStep();
      case 3:
        return _buildConcernStep();
      case 4:
        return _buildGoalStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAgeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '연령대를 알려주세요',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '맞춤형 콘텐츠를 제공하기 위해 필요해요',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ..._ageGroups.map(
          (age) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildOptionCard(age, _ageGroup == age, () {
              setState(() {
                _ageGroup = age;
              });
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildOccupationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '직업을 알려주세요',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '생활 패턴에 맞는 실천 방법을 추천해드려요',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ..._occupations.map(
          (occupation) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildOptionCard(occupation, _occupation == occupation, () {
              setState(() {
                _occupation = occupation;
              });
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '관심 있는 주제를 선택해주세요',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '여러 개 선택 가능해요 (최소 1개)',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ..._interestOptions.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildMultiSelectCard(
              entry.value,
              _interests.contains(entry.key),
              () {
                setState(() {
                  if (_interests.contains(entry.key)) {
                    _interests.remove(entry.key);
                  } else {
                    _interests.add(entry.key);
                  }
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConcernStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '환경 문제에 대해\n얼마나 걱정하시나요?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '솔직하게 답변해주세요',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ..._concernLevels.map(
          (level) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildOptionCard(level, _environmentalConcern == level, () {
              setState(() {
                _environmentalConcern = level;
              });
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          '이 앱을 통해\n무엇을 얻고 싶으신가요?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '가장 중요한 목표 하나를 선택해주세요',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 32),
        ..._goals.entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildOptionCard(entry.value, _mainGoal == entry.key, () {
              setState(() {
                _mainGoal = entry.key;
              });
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromRGBO(76, 175, 80, 0.15)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectCard(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromRGBO(76, 175, 80, 0.15)
              : Colors.grey[100],
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box : Icons.check_box_outline_blank,
              color: isSelected ? AppColors.primary : Colors.grey[400],
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _ageGroup != null;
      case 1:
        return _occupation != null;
      case 2:
        return _interests.isNotEmpty;
      case 3:
        return _environmentalConcern != null;
      case 4:
        return _mainGoal != null;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
    } else {
      _handleComplete();
    }
  }

  void _handleComplete() {
    // 설문 완료 처리
    // final surveyData = {
    //   'ageGroup': _ageGroup,
    //   'occupation': _occupation,
    //   'interests': _interests,
    //   'environmentalConcern': _environmentalConcern,
    //   'mainGoal': _mainGoal,
    // };

    // TODO: 백엔드로 데이터 전송

    // 완료 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('설문 완료! 🎉'),
        content: const Text(
          '설문을 완료했습니다!\n맞춤형 콘텐츠를 준비하고 있어요.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 메인 페이지로 이동
              // Navigator.pushNamedAndRemoveUntil(context, '/lobby', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('시작하기'),
          ),
        ],
      ),
    );
  }
}
