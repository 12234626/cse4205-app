import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/guideline_post_model.dart';
import 'services/guideline_storage.dart';
import 'guideline_write_page.dart';
import 'guideline_detail_page.dart';
import 'dart:io';

class GuidelinesPage extends StatefulWidget {
  const GuidelinesPage({super.key});

  @override
  State<GuidelinesPage> createState() => _GuidelinesPageState();
}

class _GuidelinesPageState extends State<GuidelinesPage> {
  List<GuidelinePost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    final posts = await GuidelineStorage.getPosts();
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  Future<void> _navigateToWritePage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuidelineWritePage()),
    );

    if (result == true) {
      _loadPosts(); // 게시글 목록 새로고침
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
        // 여러 줄 바꿈을 공백으로
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
        title: const Text('가이드라인 모음'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToWritePage,
            tooltip: '글쓰기',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
          ? const Center(child: Text('게시글이 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return _buildGuidelineCard(context, post: post);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToWritePage,
        backgroundColor: AppColors.primary,
        tooltip: '글쓰기',
        child: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildGuidelineCard(
    BuildContext context, {
    required GuidelinePost post,
  }) {
    final String displayTitle = '[${post.category}] ${post.title}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          // 게시글 상세보기
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuidelineDetailPage(post: post),
            ),
          );

          // 게시글이 수정되거나 삭제된 경우 목록 새로고침
          if (result == true) {
            _loadPosts();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getPreviewText(post.content),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              if (post.imageUrl != null) ...[
                const SizedBox(width: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildThumbnail(post.imageUrl!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    // 로컬 파일인지 URL인지 확인
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[300],
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      );
    }
  }
}
