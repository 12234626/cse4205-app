import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../common/constants.dart';
import '../../models/community_post_model.dart';
import '../../services/api_service.dart';

class CommunityDetailPage extends StatefulWidget {
  final CommunityPost post;

  const CommunityDetailPage({super.key, required this.post});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  bool _isLiked = false;
  int _likeCount = 0;
  List<String> _presignedImageUrls = []; // Presigned URL로 변환된 이미지 목록
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likes;
    _loadPresignedImages();
  }

  // S3 이미지 URL을 Presigned GET URL로 변환
  Future<void> _loadPresignedImages() async {
    if (widget.post.images == null || widget.post.images!.isEmpty) {
      return;
    }

    setState(() => _isLoadingImages = true);

    try {
      final presignedUrls = <String>[];

      for (final imageUrl in widget.post.images!) {
        try {
          // URL 인코딩하여 쿼리 파라미터로 추가
          final encodedUrl = Uri.encodeComponent(imageUrl);
          final response = await ApiService.get(
            '/api/upload/presigned-get-url?fileUrl=$encodedUrl',
          );

          if (response.success && response.data != null) {
            presignedUrls.add(response.data['url']);
          } else {
            debugPrint('[DEBUG] Presigned URL 생성 실패: $imageUrl');
          }
        } catch (e) {
          debugPrint('[DEBUG] Presigned URL 생성 오류: $e');
        }
      }

      if (mounted) {
        setState(() {
          _presignedImageUrls = presignedUrls;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      debugPrint('[DEBUG] 이미지 로드 오류: $e');
      if (mounted) {
        setState(() => _isLoadingImages = false);
      }
    }
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      widget.post.title,
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
                          child: const Icon(Icons.person, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.authorNickname,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.post.date,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.post.views.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // 내용 (Markdown 렌더링)
                    MarkdownBody(
                      data: widget.post.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(fontSize: 16, height: 1.6),
                        h1: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h4: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // 이미지 표시 (Presigned URL)
                    if (_isLoadingImages)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_presignedImageUrls.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      ..._presignedImageUrls.map(
                        (imageUrl) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint('[DEBUG] 이미지 로드 실패: $imageUrl');
                                return Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error,
                                        size: 48,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '이미지를 불러올 수 없습니다',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ] else if (widget.post.imageUrl != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.post.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // 인증 완료 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleLike,
                        icon: Icon(
                          _isLiked
                              ? Icons.check_circle
                              : Icons.check_circle_outline,
                        ),
                        label: Text('인증 완료 $_likeCount'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLiked
                              ? AppColors.primary
                              : Colors.grey[200],
                          foregroundColor: _isLiked
                              ? Colors.white
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
