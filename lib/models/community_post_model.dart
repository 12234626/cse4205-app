class CommunityPost {
  final String id;
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
      id: json['id'],
      authorId: json['authorId'],
      authorNickname: json['authorNickname'],
      title: json['title'],
      content: json['content'],
      date: json['date'],
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      dislikes: json['dislikes'] ?? 0,
      comments: json['comments'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
