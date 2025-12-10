import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/community_post_model.dart';
import '../../services/api_service.dart';
import 'community_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<CommunityPost> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('/api/consent-request/community');

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _posts = (response.data as List)
                .map((post) {
                  try {
                    // createdAt 날짜 파싱
                    String dateStr;
                    try {
                      final createdAt = post['createdAt'];
                      if (createdAt != null && createdAt is String && createdAt.length >= 10) {
                        dateStr = createdAt.substring(0, 10);
                      } else {
                        dateStr = DateTime.now().toString().substring(0, 10);
                      }
                    } catch (e) {
                      dateStr = DateTime.now().toString().substring(0, 10);
                    }
                    
                    return CommunityPost(
                      id: post['consentRequestId'].toString(),
                      authorId: post['author']['userId'].toString(),
                      authorNickname: post['author']['username'] ?? '사용자',
                      title: post['title'] ?? '제목 없음',
                      content: post['content'] ?? '',
                      date: dateStr,
                      views: 0, // API에 views 없음
                      likes: post['reviews']?.length ?? 0, // 리뷰 수를 likes로 사용
                      comments: 0, // 댓글 기능 제거됨
                    );
                  } catch (e) {
                    return null;
                  }
                })
                .where((post) => post != null)
                .cast<CommunityPost>()
                .toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                response.message?.toString() ??
                    '게시글을 불러오지 못했습니다.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
    }
  }

  // 마크다운 문법 제거 및 첫 번째 문장 추출
  String _getPreviewText(String content) {
    // 마크다운 문법 제거
    String cleaned = content
        // 제목 (# ## ### ####)
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        // 굵게 (**)
        .replaceAllMapped(
          RegExp(r'\*\*(.*?)\*\*'),
          (match) => match.group(1) ?? '',
        )
        // 기울이기 (*)
        .replaceAllMapped(RegExp(r'\*(.*?)\*'), (match) => match.group(1) ?? '')
        // 밑줄 (<u></u>)
        .replaceAllMapped(
          RegExp(r'<u>(.*?)</u>'),
          (match) => match.group(1) ?? '',
        )
        // 리스트 (-)
        .replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '')
        // 여러 줄 바꾸김을 공백으로
        .replaceAll(RegExp(r'\n+'), ' ')
        // 여러 공백을 하나로
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    // 첫 번째 문장 추출 (마침표, 느낌표, 물음표 기준)
    final match = RegExp(r'^(.*?[.!?]\s*)').firstMatch(cleaned);
    String preview = match != null ? match.group(1)! : cleaned;

    // 최대 50자로 제한
    if (preview.length > 50) {
      preview = '${preview.substring(0, 50)}...';
    }

    return preview;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('인증 게시판'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPosts,
                child: _posts.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 게시글이 없습니다.\n첫 게시글을 작성해보세요!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _posts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로비 페이지에서 퀘스트 카드의 인증 버튼을 눌러 게시글을 작성하세요.'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        tooltip: '글쓰기',
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommunityDetailPage(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                _getPreviewText(post.content),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 작성자 및 통계
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.authorNickname,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.views.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.likes.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.thumb_down, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.dislikes.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.comments.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
