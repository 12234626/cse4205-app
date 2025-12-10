import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../common/constants.dart';
import '../../models/consent_post_model.dart';
import '../../services/api_service.dart';

class ConsentPostDetailPage extends StatefulWidget {
  final int userQuestId;
  final String requestType;

  const ConsentPostDetailPage({
    super.key,
    required this.userQuestId,
    required this.requestType,
  });

  @override
  State<ConsentPostDetailPage> createState() => _ConsentPostDetailPageState();
}

class _ConsentPostDetailPageState extends State<ConsentPostDetailPage> {
  ConsentPost? _post;
  bool _isLoading = true;
  String? _errorMessage;
  String _currentUserRole = 'MENTEE';
  int? _currentUserId;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadUserInfo();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    try {
      final response = await ApiService.get('/api/user/profile');
      if (response.success && response.data != null) {
        setState(() {
          _currentUserRole = response.data['role'] ?? 'MENTEE';
          _currentUserId = response.data['userId'];
        });
      }
    } catch (e) {
      // 프로필 로드 실패 시 기본값 유지
    }
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        '/api/consent-request/${widget.requestType}/${widget.userQuestId}',
      );

      if (response.success && response.data != null) {
        debugPrint('API Response: ${response.data}');
        try {
          setState(() {
            _post = ConsentPost.fromJson(response.data);
            _isLoading = false;
          });
        } catch (parseError) {
          debugPrint('Parse Error: $parseError');
          setState(() {
            _errorMessage = '게시글 파싱 오류: ${parseError.toString()}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = response.message?.toString() ?? '게시글을 불러올 수 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load Post Error: $e');
      setState(() {
        _errorMessage = '오류가 발생했습니다: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글 내용을 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiService.post(
        '/api/consent-review/${widget.requestType}/${widget.userQuestId}',
        body: {
          'comment': _commentController.text.trim(),
        },
      );

      if (response.success) {
        _commentController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증이 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        // 게시글 새로고침
        _loadPost();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message?.toString() ?? '인증에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  bool _hasUserReviewed() {
    if (_post == null || _currentUserId == null) return false;
    return _post!.reviews.any((review) => review.reviewer.userId == _currentUserId);
  }

  int _getCommunityReviewCount() {
    if (_post == null) return 0;
    // 직속 멘토가 아닌 리뷰만 카운트 (실제로는 author.mentor 정보 필요)
    return _post!.reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('게시글 상세'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadPost,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                )
              : _post == null
                  ? const Center(child: Text('게시글을 찾을 수 없습니다.'))
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목
                                Text(
                                  _post!.title ?? '제목 없음',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 작성자 정보
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryLight,
                                      child: Text(
                                        _post!.author.username[0].toUpperCase(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _post!.author.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _post!.createdAt.length >= 10
                                              ? _post!.createdAt.substring(0, 10)
                                              : _post!.createdAt,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 32),

                                // 내용 (Markdown 렌더링)
                                if (_post!.content != null)
                                  MarkdownBody(
                                    data: _post!.content!,
                                    selectable: true,
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(fontSize: 16, height: 1.6),
                                      h1: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                // 이미지들
                                if (_post!.images.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  ..._post!.images.map((image) => Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            image.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Container(
                                                  height: 200,
                                                  color: Colors.grey[300],
                                                  child: const Icon(Icons.error),
                                                ),
                                          ),
                                        ),
                                      )),
                                ],

                                const SizedBox(height: 24),

                                // 커뮤니티 인증 상태 박스
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green[700],
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '커뮤니티 인증 ${_getCommunityReviewCount()} / 3',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // 댓글 섹션
                                Text(
                                  '댓글 (${_post!.reviews.length})',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // 댓글 목록
                                ..._post!.reviews.map((review) => _buildCommentCard(review)),
                              ],
                            ),
                          ),
                        ),

                        // 댓글 입력 영역
                        _buildCommentInput(),
                      ],
                    ),
    );
  }

  Widget _buildCommentCard(ConsentReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.secondaryLight,
                  child: Text(
                    review.reviewer.username[0].toUpperCase(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.reviewer.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '멘토',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    // 멘티인 경우
    if (_currentUserRole == 'MENTEE') {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '멘티는 인증 과정에 참여할 수 없습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 이미 인증에 참여한 경우
    if (_hasUserReviewed()) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(top: BorderSide(color: Colors.blue[200]!)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue[700]),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '이미 인증에 참여하였습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 멘토이고 아직 인증하지 않은 경우 - 댓글 입력창
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              enabled: !_isSubmitting,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'lgtm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            onPressed: _isSubmitting ? null : _submitReview,
            backgroundColor: AppColors.primary,
            mini: true,
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }
}
