import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/community_post_model.dart';
import '../../services/api_service.dart';
import 'consent_post_detail_page.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<CommunityPost> _posts = [];
  List<CommunityPost> _allPosts = [];
  bool _isLoading = false;
  String _selectedStatus = 'PENDING'; // PENDING or CONSENTED

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  void _filterPosts() {
    setState(() {
      if (_selectedStatus == 'PENDING') {
        _posts = _allPosts.where((post) => post.likes < 3).toList();
      } else {
        _posts = _allPosts.where((post) => post.likes > 2).toList();
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('/api/consent-request/community');

      if (response.success && response.data != null) {
        if (mounted) {
          final List<CommunityPost> posts = [];

          for (var postData in response.data as List) {
            try {
              // API 응답 구조:
              // - consentRequestId: number
              // - userQuestId: number
              // - title: string | null
              // - content: string | null (마크다운 형식)
              // - createdAt: Date (ISO 8601 문자열)
              // - updatedAt: Date
              // - author: { userId, role, username, avatarUrl, exp, level, ... }
              // - images: [{ consentRequestImageId, imageUrl }]
              // - reviews: [{ consentReviewId, comment, createdAt, reviewer: UserDto }]

              // author를 안전하게 추출
              final authorData = postData['author'];
              if (authorData == null || authorData is! Map<String, dynamic>) {
                debugPrint('Invalid author data: $authorData');
                continue;
              }
              final author = authorData;

              // reviews를 안전하게 추출하고 유효한 reviewer가 있는 것만 필터링
              final reviewsData = postData['reviews'];
              List<dynamic> reviews = [];
              if (reviewsData is List) {
                reviews = reviewsData.where((review) {
                  // reviewer가 null이 아니고 Map인 경우만 포함
                  return review != null &&
                      review is Map<String, dynamic> &&
                      review['reviewer'] != null;
                }).toList();
              }

              // content를 안전하게 문자열로 변환
              final rawContent = postData['content'];
              String contentText;

              if (rawContent is Map<String, dynamic>) {
                contentText = rawContent['text']?.toString() ?? '';
              } else if (rawContent is String) {
                contentText = rawContent;
              } else {
                contentText = rawContent?.toString() ?? '';
              }

              // createdAt을 날짜 형식으로 변환
              String dateStr;
              try {
                final createdAt = postData['createdAt'];
                if (createdAt is String) {
                  // ISO 8601 형식의 문자열에서 날짜 부분만 추출
                  dateStr = createdAt.split('T')[0];
                } else {
                  dateStr = DateTime.now().toIso8601String().split('T')[0];
                }
              } catch (e) {
                debugPrint('날짜 파싱 오류: $e');
                dateStr = DateTime.now().toIso8601String().split('T')[0];
              }

              // userQuestId 안전하게 파싱
              final userQuestId = postData['userQuestId'];
              int userQuestIdInt;
              if (userQuestId is int) {
                userQuestIdInt = userQuestId;
              } else {
                userQuestIdInt =
                    int.tryParse(userQuestId?.toString() ?? '0') ?? 0;
              }

              // userId 안전하게 파싱
              final userId = author['userId'];
              String userIdStr;
              if (userId is int) {
                userIdStr = userId.toString();
              } else {
                userIdStr = userId?.toString() ?? '0';
              }

              final post = CommunityPost(
                id: postData['consentRequestId'].toString(),
                userQuestId: userQuestIdInt,
                authorId: userIdStr,
                authorNickname: author['username']?.toString() ?? '사용자',
                title: postData['title']?.toString() ?? '제목 없음',
                content: contentText,
                date: dateStr,
                views: 0,
                likes: reviews.length,
                comments: 0,
              );

              posts.add(post);
            } catch (e, stackTrace) {
              // 개별 게시글 파싱 실패 시 로그 출력하고 계속 진행
              debugPrint('게시글 파싱 오류: $e');
              debugPrint('Stack trace: $stackTrace');
            }
          }

          setState(() {
            _allPosts = posts;
            _isLoading = false;
          });
          _filterPosts();
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message?.toString() ?? '게시글을 불러오지 못했습니다.'),
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
        child: Column(
          children: [
            // 카테고리 버튼
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedStatus = 'PENDING');
                        _filterPosts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == 'PENDING'
                            ? AppColors.primary
                            : Colors.grey[300],
                        foregroundColor: _selectedStatus == 'PENDING'
                            ? Colors.white
                            : Colors.black87,
                        elevation: _selectedStatus == 'PENDING' ? 4 : 0,
                      ),
                      child: const Text('인증 대기중'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _selectedStatus = 'CONSENTED');
                        _filterPosts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedStatus == 'CONSENTED'
                            ? AppColors.primary
                            : Colors.grey[300],
                        foregroundColor: _selectedStatus == 'CONSENTED'
                            ? Colors.white
                            : Colors.black87,
                        elevation: _selectedStatus == 'CONSENTED' ? 4 : 0,
                      ),
                      child: const Text('인증 완료'),
                    ),
                  ),
                ],
              ),
            ),
            // 게시글 목록
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadPosts,
                      child: _posts.isEmpty
                          ? const Center(
                              child: Text(
                                '아직 게시글이 없습니다.\n첫 게시글을 작성해보세요!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
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
          ],
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
              builder: (context) => ConsentPostDetailPage(
                userQuestId: post.userQuestId,
                requestType: 'COMMUNITY',
              ),
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
                _getPreviewText(post.content.toString()),
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
                  Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.likes.toString(),
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
