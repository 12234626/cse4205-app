import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'constants.dart';
import 'models/guideline_post_model.dart';
import 'services/guideline_storage.dart';

class GuidelineWritePage extends StatefulWidget {
  final GuidelinePost? postToEdit;

  const GuidelineWritePage({super.key, this.postToEdit});

  @override
  State<GuidelineWritePage> createState() => _GuidelineWritePageState();
}

class _GuidelineWritePageState extends State<GuidelineWritePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _selectedCategory = '일일퀘스트';
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  // 수정 모드 관련 변수
  String? _originalTitle;
  String? _originalContent;
  String? _originalCategory;
  String? _originalImagePath;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _loadPostToEdit();
    } else {
      _loadDraft();
    }
  }

  Future<void> _loadPostToEdit() async {
    final post = widget.postToEdit!;
    setState(() {
      _titleController.text = post.title;
      _contentController.text = post.content;
      _selectedCategory = post.category;
      _imagePath = post.imageUrl;

      // 원본 저장
      _originalTitle = post.title;
      _originalContent = post.content;
      _originalCategory = post.category;
      _originalImagePath = post.imageUrl;
    });
  }

  Future<void> _loadDraft() async {
    final draft = await GuidelineStorage.getDraft();
    if (draft != null) {
      setState(() {
        _titleController.text = draft.title;
        _contentController.text = draft.content;
        _selectedCategory = draft.category;
        _imagePath = draft.imageUrl;
      });
    }
  }

  bool get _hasChanges {
    if (widget.postToEdit == null) return false;
    return _titleController.text != _originalTitle ||
        _contentController.text != _originalContent ||
        _selectedCategory != _originalCategory ||
        _imagePath != _originalImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _hasContent {
    return _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty;
  }

  Future<void> _showExitDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('작성이 완료되지 않은 내용이 있습니다. 나가시겠습니까?'),
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

    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveDraft() async {
    final post = GuidelinePost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now().toString().substring(0, 19),
      imageUrl: _imagePath,
      isDraft: true,
    );

    await GuidelineStorage.saveDraft(post);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('임시저장되었습니다.')));
    }
  }

  Future<void> _publishPost() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요.')));
      return;
    }

    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요.')));
      return;
    }

    // 수정 모드인 경우
    if (widget.postToEdit != null) {
      final updatedPost = GuidelinePost(
        id: widget.postToEdit!.id,
        category: _selectedCategory,
        title: _titleController.text,
        content: _contentController.text,
        date: widget.postToEdit!.date,
        imageUrl: _imagePath,
        isDraft: false,
      );

      final posts = await GuidelineStorage.getPosts();
      final index = posts.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        posts[index] = updatedPost;
        await GuidelineStorage.savePosts(posts);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
      return;
    }

    // 신규 작성 모드인 경우
    final post = GuidelinePost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory,
      title: _titleController.text,
      content: _contentController.text,
      date: DateTime.now().toString().substring(0, 19),
      imageUrl: _imagePath,
      isDraft: false,
    );

    await GuidelineStorage.addPost(post);
    await GuidelineStorage.deleteDraft();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지를 선택할 수 없습니다: $e')));
      }
    }
  }

  Future<void> _showCategoryDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카테고리 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  _selectedCategory == '일일퀘스트'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                title: const Text('일일퀘스트'),
                onTap: () => Navigator.of(context).pop('일일퀘스트'),
              ),
              ListTile(
                leading: Icon(
                  _selectedCategory == '주간퀘스트'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                ),
                title: const Text('주간퀘스트'),
                onTap: () => Navigator.of(context).pop('주간퀘스트'),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategory = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasContent,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _hasContent) {
          _showExitDialog();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_hasContent) {
                _showExitDialog();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(widget.postToEdit != null ? '글 수정' : '글쓰기'),
          actions: [
            if (widget.postToEdit == null)
              TextButton(
                onPressed: _saveDraft,
                child: const Text(
                  '임시저장',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            TextButton(
              onPressed: widget.postToEdit != null && !_hasChanges
                  ? null
                  : _publishPost,
              child: Text(
                widget.postToEdit != null ? '수정' : '등록',
                style: TextStyle(
                  color: widget.postToEdit != null && !_hasChanges
                      ? Colors.grey[400]
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 카테고리 선택 버튼
            InkWell(
              onTap: _showCategoryDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '구분: $_selectedCategory',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),

            // 제목 입력
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '제목',
                  border: InputBorder.none,
                ),
              ),
            ),

            const Divider(height: 1),

            // 내용 입력
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _contentController,
                  onChanged: (_) => setState(() {}),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: '내용을 입력하세요...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            // 이미지 미리보기
            if (_imagePath != null)
              Container(
                margin: const EdgeInsets.all(16.0),
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(_imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // 하단 바 (사진 첨부 버튼)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: _pickImage,
                    tooltip: '사진 첨부',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
