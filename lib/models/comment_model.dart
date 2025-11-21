class Comment {
  final String id;
  final String postId;
  final String author;
  final String content;
  final String date;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'author': author,
      'content': content,
      'date': date,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      postId: json['postId'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      date: json['date'] as String,
    );
  }
}
