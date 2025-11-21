import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/guideline_post_model.dart';

class GuidelineStorage {
  static const String _postsKey = 'guideline_posts';
  static const String _draftKey = 'guideline_draft';

  // 모든 게시글 가져오기 (임시저장 제외)
  static Future<List<GuidelinePost>> getPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? postsJson = prefs.getString(_postsKey);

    if (postsJson == null) {
      // 초기 데이터 생성
      return [
        GuidelinePost(
          id: '1',
          category: '일일퀘스트',
          title: '분리수거 가이드라인',
          content: '테스트 내용입니다.',
          date: '2025-01-18',
          imageUrl:
              'https://plus.unsplash.com/premium_photo-1681987448179-4a93b7975018?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        ),
      ];
    }

    final List<dynamic> jsonList = json.decode(postsJson);
    return jsonList
        .map((json) => GuidelinePost.fromJson(json))
        .where((post) => !post.isDraft)
        .toList();
  }

  // 게시글 저장
  static Future<void> savePosts(List<GuidelinePost> posts) async {
    final prefs = await SharedPreferences.getInstance();
    final String postsJson = json.encode(
      posts.map((post) => post.toJson()).toList(),
    );
    await prefs.setString(_postsKey, postsJson);
  }

  // 게시글 추가
  static Future<void> addPost(GuidelinePost post) async {
    final posts = await getPosts();
    posts.insert(0, post); // 최신 게시글을 상단에
    await savePosts(posts);
  }

  // 임시저장된 게시글 가져오기
  static Future<GuidelinePost?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftJson = prefs.getString(_draftKey);

    if (draftJson == null) return null;

    return GuidelinePost.fromJson(json.decode(draftJson));
  }

  // 임시저장
  static Future<void> saveDraft(GuidelinePost post) async {
    final prefs = await SharedPreferences.getInstance();
    final String draftJson = json.encode(post.toJson());
    await prefs.setString(_draftKey, draftJson);
  }

  // 임시저장 삭제
  static Future<void> deleteDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }
}
