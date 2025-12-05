import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/carbon_survey.dart';

class CarbonSurveyResultPage extends StatelessWidget {
  final CarbonSurveyResult result;

  const CarbonSurveyResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('설문 결과'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/lobby', (route) => false);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 메인 레벨 카드
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: AppColors.appBarGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '나의 탄소중립 실천 레벨',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        carbonLevelEmoji(result.level),
                        style: const TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        carbonLevelLabel(result.level),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${result.score100}점',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        carbonLevelDescription(result.level),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 카테고리별 점수
              const Text(
                '영역별 실천 점수',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildCategoryCard(
                '⚡ 에너지/이동',
                result.energyPct,
                _getCategoryComment(result.energyPct),
              ),
              _buildCategoryCard(
                '🍽️ 식습관/소비',
                result.foodPct,
                _getCategoryComment(result.foodPct),
              ),
              _buildCategoryCard(
                '♻️ 자원순환',
                result.wastePct,
                _getCategoryComment(result.wastePct),
              ),
              _buildCategoryCard(
                '💪 실천 의지',
                result.willPct,
                _getCategoryComment(result.willPct),
              ),

              const SizedBox(height: 24),

              // CTA 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/lobby', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 8,
                    shadowColor: Color.fromRGBO(0, 0, 0, 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    '홈으로 돌아가기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, double percentage, String comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.round()}점',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(percentage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getScoreColor(percentage),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 80) {
      return Colors.green;
    } else if (percentage >= 60) {
      return Colors.lightGreen;
    } else if (percentage >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getCategoryComment(double percentage) {
    if (percentage >= 80) {
      return "훌륭해요! 이미 잘 실천하고 있어요 👍";
    } else if (percentage >= 60) {
      return "잘하고 있어요! 조금만 더 노력하면 완벽해요";
    } else if (percentage >= 40) {
      return "괜찮아요! 조금씩 개선해 나가보세요";
    } else {
      return "이 영역에 조금 더 관심을 가져보세요";
    }
  }
}
