class GuidelinePost {
  final int questId;
  final String title;
  final String description;
  final String category;
  final String questType;
  final int expReward;
  final int levelRequired;
  final String difficulty;

  GuidelinePost({
    required this.questId,
    required this.title,
    required this.description,
    required this.category,
    required this.questType,
    required this.expReward,
    required this.levelRequired,
    required this.difficulty,
  });

  // JSON에서 생성
  factory GuidelinePost.fromJson(Map<String, dynamic> json) {
    return GuidelinePost(
      questId: json['questId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      questType: json['questType'] as String,
      expReward: json['expReward'] as int,
      levelRequired: json['levelRequired'] as int,
      difficulty: json['difficulty'] as String,
    );
  }
}
