import 'package:flutter/material.dart';
import 'dart:io';
import 'constants.dart';
import 'models/guideline_post_model.dart';
import 'models/comment_model.dart';
import 'services/guideline_storage.dart';
import 'services/comment_storage.dart';
import 'guideline_write_page.dart';

class GuidelineDetailPage extends StatefulWidget {
  final GuidelinePost post;

  const GuidelineDetailPage({super.key, required this.post});

  @override
  State<GuidelineDetailPage> createState() => _GuidelineDetailPageState();
}

class _GuidelineDetailPageState extends State<GuidelineDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isAscending = false;
  int _currentPage = 1;
  final int _commentsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final comments = await CommentStorage.getComments(widget.post.id);
    setState(() {
      _comments = comments;
      _sortComments();
    });
  }

  void _sortComments() {
    if (_isAscending) {
      _comments.sort((a, b) => a.date.compareTo(b.date));
    } else {
      _comments.sort((a, b) => b.date.compareTo(a.date));
    }
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _sortComments();
      _currentPage = 1;
    });
  }

  bool get _canAddComment {
    final text = _commentController.text.trim();
    return text.isNotEmpty && text.replaceAll(RegExp(r'\s'), '').isNotEmpty;
  }

  Future<void> _addComment() async {
    if (!_canAddComment) return;

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      author: '사용자',
      content: _commentController.text.trim(),
      date: DateTime.now().toString().substring(0, 19),
    );

    await CommentStorage.addComment(comment);
    _commentController.clear();
    await _loadComments();
  }

  Future<void> _deleteComment(String commentId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('댓글 삭제'),
          content: const Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('예'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await CommentStorage.deleteComment(commentId);
      await _loadComments();
    }
  }

  Future<void> _editPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuidelineWritePage(postToEdit: widget.post),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deletePost() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('정말 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('예'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final posts = await GuidelineStorage.getPosts();
      posts.removeWhere((p) => p.id == widget.post.id);
      await GuidelineStorage.savePosts(posts);
      await CommentStorage.deleteCommentsByPostId(widget.post.id);

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  int get _totalPages => (_comments.length / _commentsPerPage).ceil();

  List<Comment> get _paginatedComments {
    final startIndex = (_currentPage - 1) * _commentsPerPage;
    final endIndex = startIndex + _commentsPerPage;
    return _comments.sublist(
      startIndex,
      endIndex > _comments.length ? _comments.length : endIndex,
    );
  }

  List<int> get _pageNumbers {
    final start = (((_currentPage - 1) ~/ 5) * 5) + 1;
    final end = (start + 4) > _totalPages ? _totalPages : (start + 4);
    return List.generate(end - start + 1, (index) => start + index);
  }

  @override
  Widget build(BuildContext context) {
    final String displayTitle =
        '[${widget.post.category}] ${widget.post.title}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('가이드라인 상세'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.post.date,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),

                  // 수정/삭제 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: _editPost,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('수정', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: _deletePost,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text('삭제', style: TextStyle(fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // 이미지
                  if (widget.post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildDetailImage(widget.post.imageUrl!),
                    ),

                  // 내용
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // 추천/비추천
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.thumb_up_outlined,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text('0', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          Icon(
                            Icons.thumb_down_outlined,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text('0', style: TextStyle(color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // 댓글 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _comments.isEmpty ? '댓글' : '댓글 (${_comments.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: _toggleSort,
                        child: Row(
                          children: [
                            const Text('최신순'),
                            const SizedBox(width: 4),
                            Icon(
                              _isAscending
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 댓글 목록
                  ..._paginatedComments.map(
                    (comment) => _buildCommentItem(comment),
                  ),

                  // 페이지네이션
                  if (_totalPages > 0) ...[
                    const SizedBox(height: 16),
                    _buildPagination(),
                  ],
                ],
              ),
            ),
          ),

          // 댓글 입력란
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _canAddComment ? _addComment : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Comment comment) {
    const String defaultProfileImageUrl =
        'https://images.unsplash.com/photo-1587334274328-64186a80aeee?q=80&w=1162&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 사진
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(defaultProfileImageUrl),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 12),
              // 댓글 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            comment.author,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, size: 20),
                          padding: EdgeInsets.zero,
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditCommentDialog(comment);
                            } else if (value == 'delete') {
                              _deleteComment(comment.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Text('수정'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey[300]),
      ],
    );
  }

  Future<void> _showEditCommentDialog(Comment comment) async {
    final TextEditingController editController =
        TextEditingController(text: comment.content);
    String originalContent = comment.content;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool hasChanges = editController.text.trim() != originalContent;
            bool canSave = editController.text.trim().isNotEmpty &&
                editController.text.trim().replaceAll(RegExp(r'\s'), '').isNotEmpty;

            return AlertDialog(
              title: const Text('댓글 수정'),
              content: TextField(
                controller: editController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '댓글을 입력하세요...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setDialogState(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: hasChanges && canSave
                      ? () async {
                          final updatedComment = Comment(
                            id: comment.id,
                            postId: comment.postId,
                            author: comment.author,
                            content: editController.text.trim(),
                            date: DateTime.now().toString().substring(0, 19),
                          );

                          final comments = await CommentStorage.getAllComments();
                          final index = comments.indexWhere((c) => c.id == comment.id);
                          if (index != -1) {
                            comments[index] = updatedComment;
                            await CommentStorage.saveComments(comments);
                          }

                          if (mounted) {
                            Navigator.of(context).pop();
                            await _loadComments();
                          }
                        }
                      : null,
                  child: Text(
                    '수정',
                    style: TextStyle(
                      color: hasChanges && canSave ? null : Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPagination() {
    final pageNumbers = _pageNumbers;
    final showPrevGroup = pageNumbers.first > 1;
    final showNextGroup = pageNumbers.last < _totalPages;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showPrevGroup)
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: () {
              setState(() {
                _currentPage = pageNumbers.first - 1;
              });
            },
          ),
        ...pageNumbers.map((page) {
          return TextButton(
            onPressed: () {
              setState(() {
                _currentPage = page;
              });
            },
            child: Text(
              '$page',
              style: TextStyle(
                fontWeight: _currentPage == page
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: _currentPage == page ? 18 : 16,
              ),
            ),
          );
        }),
        if (showNextGroup)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              setState(() {
                _currentPage = pageNumbers.last + 1;
              });
            },
          ),
      ],
    );
  }

  Widget _buildDetailImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(imageUrl),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.image, size: 50, color: Colors.grey),
            ),
          );
        },
      );
    }
  }
}
