// 작성자 정보
class ConsentAuthor {
  final int userId;
  final String role;
  final String username;
  final String? avatarUrl;
  final int exp;
  final int level;

  ConsentAuthor({
    required this.userId,
    required this.role,
    required this.username,
    this.avatarUrl,
    required this.exp,
    required this.level,
  });

  factory ConsentAuthor.fromJson(Map<String, dynamic> json) {
    return ConsentAuthor(
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId'].toString()) ?? 0,
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '사용자',
      avatarUrl: json['avatarUrl']?.toString(),
      exp: json['exp'] is int
          ? json['exp'] as int
          : int.tryParse(json['exp'].toString()) ?? 0,
      level: json['level'] is int
          ? json['level'] as int
          : int.tryParse(json['level'].toString()) ?? 0,
    );
  }
}

// 이미지 정보
class ConsentImage {
  final int consentRequestImageId;
  final String imageUrl;

  ConsentImage({required this.consentRequestImageId, required this.imageUrl});

  factory ConsentImage.fromJson(Map<String, dynamic> json) {
    return ConsentImage(
      consentRequestImageId: json['consentRequestImageId'] is int
          ? json['consentRequestImageId'] as int
          : int.tryParse(json['consentRequestImageId'].toString()) ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}

// 리뷰어 정보
class ConsentReviewer {
  final int userId;
  final String role;
  final String username;
  final String? avatarUrl;

  ConsentReviewer({
    required this.userId,
    required this.role,
    required this.username,
    this.avatarUrl,
  });

  factory ConsentReviewer.fromJson(Map<String, dynamic> json) {
    return ConsentReviewer(
      userId: json['userId'] is int
          ? json['userId'] as int
          : int.tryParse(json['userId'].toString()) ?? 0,
      role: json['role']?.toString() ?? '',
      username: json['username']?.toString() ?? '사용자',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }
}

// 리뷰(댓글) 정보
class ConsentReview {
  final int consentReviewId;
  final String? comment;
  final String createdAt;
  final ConsentReviewer reviewer;

  ConsentReview({
    required this.consentReviewId,
    this.comment,
    required this.createdAt,
    required this.reviewer,
  });

  factory ConsentReview.fromJson(Map<String, dynamic> json) {
    return ConsentReview(
      consentReviewId: json['consentReviewId'] is int
          ? json['consentReviewId'] as int
          : int.tryParse(json['consentReviewId'].toString()) ?? 0,
      comment: json['comment']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      reviewer: ConsentReviewer.fromJson(
        (json['reviewer'] ?? const {}) as Map<String, dynamic>,
      ),
    );
  }
}

// 인증 게시글 모델
class ConsentPost {
  final int consentRequestId;
  final int userQuestId;
  final String requestType;
  final String? title;
  final String? content;
  final String createdAt;
  final String updatedAt;
  final ConsentAuthor author;
  final List<ConsentImage> images;
  final List<ConsentReview> reviews;

  ConsentPost({
    required this.consentRequestId,
    required this.userQuestId,
    required this.requestType,
    this.title,
    this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.images,
    required this.reviews,
  });

  factory ConsentPost.fromJson(Map<String, dynamic> json) {
    // content를 안전하게 문자열로 변환
    final rawContent = json['content'];
    String? contentText;
    if (rawContent is Map<String, dynamic>) {
      contentText = rawContent['text']?.toString();
    } else if (rawContent != null) {
      contentText = rawContent.toString();
    }

    // createdAt를 안전하게 문자열로 변환
    final rawCreatedAt = json['createdAt'];
    String createdAtStr = '';
    if (rawCreatedAt is String) {
      createdAtStr = rawCreatedAt;
    } else if (rawCreatedAt is Map && rawCreatedAt.isNotEmpty) {
      // ISO 8601 형식의 날짜 객체인 경우 처리
      createdAtStr = DateTime.now().toIso8601String();
    }

    // updatedAt를 안전하게 문자열로 변환
    final rawUpdatedAt = json['updatedAt'];
    String updatedAtStr = '';
    if (rawUpdatedAt is String) {
      updatedAtStr = rawUpdatedAt;
    } else if (rawUpdatedAt is Map && rawUpdatedAt.isNotEmpty) {
      updatedAtStr = DateTime.now().toIso8601String();
    }

    return ConsentPost(
      consentRequestId: json['consentRequestId'] is int
          ? json['consentRequestId'] as int
          : int.tryParse(json['consentRequestId'].toString()) ?? 0,
      userQuestId: json['userQuestId'] is int
          ? json['userQuestId'] as int
          : int.tryParse(json['userQuestId'].toString()) ?? 0,
      requestType: json['requestType']?.toString() ?? '',
      title: json['title']?.toString(),
      content: contentText,
      createdAt: createdAtStr,
      updatedAt: updatedAtStr,
      author: ConsentAuthor.fromJson(
        (json['author'] ?? const {}) as Map<String, dynamic>,
      ),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((img) => ConsentImage.fromJson(img as Map<String, dynamic>))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .map(
            (review) => ConsentReview.fromJson(review as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
