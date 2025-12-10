class CommunityPost {
  final String id;
  final int userQuestId;
  final String authorId;
  final String authorNickname;
  final String title;
  final String content;
  final String date;
  final int views;
  final int likes;
  final int dislikes;
  final int comments;
  final String? imageUrl;

  CommunityPost({
    required this.id,
    required this.userQuestId,
    required this.authorId,
    required this.authorNickname,
    required this.title,
    required this.content,
    required this.date,
    this.views = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.comments = 0,
    this.imageUrl,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id']?.toString() ?? json['consentRequestId']?.toString() ?? '',
      userQuestId: json['userQuestId'] as int,
      authorId: json['authorId']?.toString() ?? json['author']?['userId']?.toString() ?? '',
      authorNickname: json['authorNickname']?.toString() ?? json['author']?['username']?.toString() ?? '사용자',
      title: json['title']?.toString() ?? '제목 없음',
      content: json['content']?.toString() ?? '',
      date: json['date']?.toString() ?? DateTime.now().toString().substring(0, 10),
      views: json['views'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userQuestId': userQuestId,
      'authorId': authorId,
      'authorNickname': authorNickname,
      'title': title,
      'content': content,
      'date': date,
      'views': views,
      'likes': likes,
      'dislikes': dislikes,
      'comments': comments,
      'imageUrl': imageUrl,
    };
  }
}
