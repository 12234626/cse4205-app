import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/community_post_model.dart';
import 'community_detail_page.dart';
import 'community_write_page.dart';

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

    // TODO: 실제 API 호출
    await Future.delayed(const Duration(milliseconds: 500));

    // 임시 데이터
    setState(() {
      _posts = [
        CommunityPost(
          id: '1',
          authorId: 'user1',
          authorNickname: '환경지킴이',
          title: '오늘 분리수거 꿀팁 공유합니다!',
          content: '플라스틱 분리배출할 때 꼭 이것만은 확인하세요...',
          date: '2025-11-28',
          views: 142,
          likes: 23,
          comments: 8,
        ),
        CommunityPost(
          id: '2',
          authorId: 'user2',
          authorNickname: '초록별',
          title: '텀블러 사용 2주차 후기',
          content: '일회용컵 대신 텀블러를 사용한지 2주가 지났습니다.',
          date: '2025-11-27',
          views: 89,
          likes: 15,
          comments: 5,
        ),
        CommunityPost(
          id: '3',
          authorId: 'user3',
          authorNickname: '에코라이프',
          title: '대중교통 이용 챌린지 성공!',
          content: '한 달간 출퇴근 대중교통으로만 다녀왔어요.',
          date: '2025-11-26',
          views: 234,
          likes: 45,
          comments: 12,
        ),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('커뮤니티'),
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
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CommunityWritePage()),
          );
          if (result == true) {
            _loadPosts();
          }
        },
        backgroundColor: AppColors.primary,
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
                post.content,
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
