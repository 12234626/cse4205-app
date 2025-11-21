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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
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
                      post.content,
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
