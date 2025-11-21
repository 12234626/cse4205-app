import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment_model.dart';

class CommentStorage {
  static const String _commentsKey = 'comments';

  // 특정 게시글의 댓글 가져오기
  static Future<List<Comment>> getComments(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? commentsJson = prefs.getString(_commentsKey);

    if (commentsJson == null) return [];

    final List<dynamic> jsonList = json.decode(commentsJson);
    return jsonList
        .map((json) => Comment.fromJson(json))
        .where((comment) => comment.postId == postId)
        .toList();
  }

  // 모든 댓글 가져오기
  static Future<List<Comment>> getAllComments() async {
    final prefs = await SharedPreferences.getInstance();
    final String? commentsJson = prefs.getString(_commentsKey);

    if (commentsJson == null) return [];

    final List<dynamic> jsonList = json.decode(commentsJson);
    return jsonList.map((json) => Comment.fromJson(json)).toList();
  }

  // 댓글 저장
  static Future<void> saveComments(List<Comment> comments) async {
    final prefs = await SharedPreferences.getInstance();
    final String commentsJson = json.encode(
      comments.map((comment) => comment.toJson()).toList(),
    );
    await prefs.setString(_commentsKey, commentsJson);
  }

  // 댓글 추가
  static Future<void> addComment(Comment comment) async {
    final comments = await getAllComments();
    comments.add(comment);
    await saveComments(comments);
  }

  // 댓글 삭제
  static Future<void> deleteComment(String commentId) async {
    final comments = await getAllComments();
    comments.removeWhere((comment) => comment.id == commentId);
    await saveComments(comments);
  }

  // 특정 게시글의 댓글 모두 삭제
  static Future<void> deleteCommentsByPostId(String postId) async {
    final comments = await getAllComments();
    comments.removeWhere((comment) => comment.postId == postId);
    await saveComments(comments);
  }
}
