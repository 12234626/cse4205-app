class GuidelinePost {
  final String id;
  final String category; // '일일퀘스트' 또는 '주간퀘스트'
  final String title;
  final String content;
  final String date;
  final String? imageUrl;
  final bool isDraft; // 임시저장 여부

  GuidelinePost({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.isDraft = false,
  });

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'date': date,
      'imageUrl': imageUrl,
      'isDraft': isDraft,
    };
  }

  // JSON에서 생성
  factory GuidelinePost.fromJson(Map<String, dynamic> json) {
    return GuidelinePost(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
      imageUrl: json['imageUrl'] as String?,
      isDraft: json['isDraft'] as bool? ?? false,
    );
  }

  // 복사본 생성
  GuidelinePost copyWith({
    String? id,
    String? category,
    String? title,
    String? content,
    String? date,
    String? imageUrl,
    bool? isDraft,
  }) {
    return GuidelinePost(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}
