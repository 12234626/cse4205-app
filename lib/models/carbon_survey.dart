/// 탄소중립 설문 10문항에 대한 레벨
enum CarbonLevel {
  seed, // Lv.1 새싹 단계
  starter, // Lv.2 시작 단계
  grower, // Lv.3 성장 단계
  challenger, // Lv.4 실천가
  guardian, // Lv.5 마스터
}

String carbonLevelLabel(CarbonLevel level) {
  switch (level) {
    case CarbonLevel.seed:
      return "Lv.1 새싹 단계";
    case CarbonLevel.starter:
      return "Lv.2 시작 단계";
    case CarbonLevel.grower:
      return "Lv.3 성장 단계";
    case CarbonLevel.challenger:
      return "Lv.4 실천가";
    case CarbonLevel.guardian:
      return "Lv.5 마스터";
  }
}

String carbonLevelDescription(CarbonLevel level) {
  switch (level) {
    case CarbonLevel.seed:
      return "이제 막 탄소중립에 관심을 갖기 시작한 단계예요.";
    case CarbonLevel.starter:
      return "몇 가지 좋은 습관을 만들기 시작한 단계예요.";
    case CarbonLevel.grower:
      return "여러 영역에서 탄소중립을 꽤 실천하고 있어요.";
    case CarbonLevel.challenger:
      return "일상 전반에서 탄소중립을 적극적으로 실천하고 있어요.";
    case CarbonLevel.guardian:
      return "일상 자체가 탄소중립 라이프에 가깝습니다.";
  }
}

String carbonLevelEmoji(CarbonLevel level) {
  switch (level) {
    case CarbonLevel.seed:
      return "🌱";
    case CarbonLevel.starter:
      return "🌿";
    case CarbonLevel.grower:
      return "🌳";
    case CarbonLevel.challenger:
      return "🏆";
    case CarbonLevel.guardian:
      return "🌍";
  }
}

/// 설문 결과 DTO
class CarbonSurveyResult {
  final int rawScore; // 10~50
  final int score100; // 0~100
  final CarbonLevel level; // Lv.1~5

  // 카테고리 퍼센트 (0~100)
  final double energyPct; // 에너지/이동: Q1~Q4
  final double foodPct; // 식습관/소비: Q5~Q7
  final double wastePct; // 자원순환: Q8~Q9
  final double willPct; // 의지/태도: Q10

  CarbonSurveyResult({
    required this.rawScore,
    required this.score100,
    required this.level,
    required this.energyPct,
    required this.foodPct,
    required this.wastePct,
    required this.willPct,
  });

  Map<String, dynamic> toJson() {
    return {
      "rawScore": rawScore,
      "score100": score100,
      "level": level.name,
      "energyPct": energyPct,
      "foodPct": foodPct,
      "wastePct": wastePct,
      "willPct": willPct,
    };
  }
}

/// 1~5점 응답 10개를 받아 결과 계산
CarbonSurveyResult calculateCarbonSurveyResult(List<int> answers) {
  if (answers.length != 10) {
    throw ArgumentError("answers must have length 10");
  }

  // 안전하게 1~5로 클램핑
  List<int> a = answers.map((v) {
    if (v < 1) return 1;
    if (v > 5) return 5;
    return v;
  }).toList();

  // 전체 raw 점수
  final rawScore = a.reduce((x, y) => x + y); // 10~50

  // 0~100 스케일로 정규화
  double normalized = (rawScore - 10) / 40 * 100;
  int score100 = normalized.round();
  if (score100 < 0) score100 = 0;
  if (score100 > 100) score100 = 100;

  // 카테고리별 raw 점수
  final energyRaw = a[0] + a[1] + a[2] + a[3]; // Q1~Q4, max 20
  final foodRaw = a[4] + a[5] + a[6]; // Q5~Q7, max 15
  final wasteRaw = a[7] + a[8]; // Q8~Q9, max 10
  final willRaw = a[9]; // Q10,    max 5

  double energyPct = energyRaw / 20 * 100;
  double foodPct = foodRaw / 15 * 100;
  double wastePct = wasteRaw / 10 * 100;
  double willPct = willRaw / 5 * 100;

  CarbonLevel level = _mapScoreToLevel(score100);

  return CarbonSurveyResult(
    rawScore: rawScore,
    score100: score100,
    level: level,
    energyPct: energyPct,
    foodPct: foodPct,
    wastePct: wastePct,
    willPct: willPct,
  );
}

CarbonLevel _mapScoreToLevel(int score100) {
  if (score100 <= 20) {
    return CarbonLevel.seed;
  } else if (score100 <= 40) {
    return CarbonLevel.starter;
  } else if (score100 <= 60) {
    return CarbonLevel.grower;
  } else if (score100 <= 80) {
    return CarbonLevel.challenger;
  } else {
    return CarbonLevel.guardian;
  }
}
