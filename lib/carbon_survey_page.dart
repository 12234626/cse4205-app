import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/carbon_survey.dart';
import 'carbon_survey_result_page.dart';

class CarbonSurveyPage extends StatefulWidget {
  const CarbonSurveyPage({super.key});

  @override
  State<CarbonSurveyPage> createState() => _CarbonSurveyPageState();
}

class _CarbonSurveyPageState extends State<CarbonSurveyPage> {
  final List<int> _answers = List.filled(10, 3); // 기본값 3(보통)

  final List<String> _questions = [
    "집에서 사용하지 않는 전등이나 전자기기를 습관적으로 끄는 편이다.",
    "냉난방(에어컨/난방) 사용 시, 옷차림이나 창문 조절 등으로 먼저 조절해 보려고 한다.",
    "가까운 거리는 가능하면 도보나 자전거, 대중교통 등 자동차 외의 수단을 이용하려고 한다.",
    "이동수단을 선택할 때, 탄소 배출이 적은 방법(대중교통, 공유 모빌리티 등)을 한 번이라도 고민해 본다.",
    "일주일 중 고기(특히 소고기) 섭취를 줄이려고 의식적으로 노력한다.",
    "옷이나 물건을 살 때, 정말 필요한지 한 번 더 생각해 보고 구매를 결정한다.",
    "새 제품을 사기 전에 중고/공유/대여 서비스를 고려해 본 적이 있다.",
    "분리수거(플라스틱, 종이, 캔, 유리 등)를 정확히 하려고 노력한다.",
    "일회용 컵 대신 텀블러나 다회용 컵을 사용하려고 한다.",
    "아직 잘 못하고 있는 부분이 있더라도, 앞으로 탄소중립 실천을 조금씩 늘려볼 의지가 있다.",
  ];

  final List<String> _scaleLabels = [
    "전혀\n그렇지 않다",
    "거의\n그렇지 않다",
    "보통이다",
    "대체로\n그렇다",
    "매우\n그렇다",
  ];

  void _submitSurvey() {
    final result = calculateCarbonSurveyResult(_answers);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonSurveyResultPage(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('탄소중립 실천 레벨 측정'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20.0),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(index);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitSurvey,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '결과 확인하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Q${index + 1}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _questions[index],
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (scaleIndex) {
                final value = scaleIndex + 1;
                final isSelected = _answers[index] == value;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _answers[index] = value;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[200],
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _scaleLabels[scaleIndex],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[600],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
