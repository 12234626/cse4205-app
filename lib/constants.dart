import 'package:flutter/material.dart';

// 앱 전체에서 사용하는 색상 상수
class AppColors {
  // 메인 테마 색상 (로고 상단 색상)
  static const Color primary = Color.fromARGB(255, 41, 255, 187);

  // 그라데이션용 보조 색상 (로고 하단 색상)
  static const Color secondary = Color.fromARGB(255, 31, 181, 229);

  // 연한 그라데이션용 색상
  static const Color primaryLight = Color.fromARGB(255, 102, 255, 204);
  static const Color secondaryLight = Color.fromARGB(255, 77, 196, 237);

  // 앱바 그라데이션 (위에서 아래로)
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryLight, secondaryLight],
  );

  // 퀘스트 카드용 밝은 그라데이션 (좌에서 우로)
  static const LinearGradient questCardGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromARGB(255, 215, 255, 240), // 매우 밝은 민트
      Color.fromARGB(255, 210, 248, 255), // 매우 밝은 하늘색
    ],
  );

  // 추가 색상이 필요하면 여기에 정의
  static const Color questCardBackground = Color.fromARGB(255, 145, 251, 253);

  // 퀘스트 달성도(프로필 페이지의 progress bar) 색상 정의
  static const Color progressBarBackground = Color.fromARGB(255, 220, 220, 220);
  static const Color progressBarFill = Color.fromARGB(255, 249, 255, 136);
}
