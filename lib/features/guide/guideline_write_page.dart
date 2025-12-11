import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../common/constants.dart';
import '../../models/guideline_post_model.dart';

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
  bool _isCategoryExpanded = false;
  bool _showPreview = false;

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

      // 수정 모드에서는 편집 모드로 시작
      _showPreview = false;

      // 원본 저장
      _originalTitle = post.title;
      _originalContent = post.content;
      _originalCategory = post.category;
      _originalImagePath = post.imageUrl;
    });
  }

  Future<void> _loadDraft() async {
    // TODO: API 연동 필요
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

  void _applyMarkdown(String prefix, {String? suffix, bool perLine = false}) {
    final text = _contentController.text;
    final selection = _contentController.selection;

    if (!selection.isValid) return;

    final selectedText = selection.textInside(text);
    String newText;

    if (perLine) {
      final lines = selectedText.split('\n');
      final modifiedLines = lines
          .map((line) {
            if (line.trim().isEmpty) return line;
            return '$prefix$line';
          })
          .join('\n');
      newText = modifiedLines;
    } else {
      newText = '$prefix$selectedText${suffix ?? ''}';
    }

    final newContent = text.replaceRange(
      selection.start,
      selection.end,
      newText,
    );

    _contentController.value = TextEditingValue(
      text: newContent,
      selection: TextSelection.collapsed(
        offset: selection.start + newText.length,
      ),
    );
  }

  void _showHeadingMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text(
                '제목 1',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _applyMarkdown('# ', perLine: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text(
                '제목 2',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _applyMarkdown('## ', perLine: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text(
                '제목 3',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _applyMarkdown('### ', perLine: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.title),
              title: const Text(
                '제목 4',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pop(context);
                _applyMarkdown('#### ', perLine: true);
              },
            ),
          ],
        ),
      ),
    );
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
    // TODO: API 연동 필요
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('임시저장 기능은 준비 중입니다.')));
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
      // TODO: API 연동 필요
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('수정 기능은 준비 중입니다.')));
      }
      return;
    }

    // 신규 작성 모드인 경우
    // TODO: API 연동 필요
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('등록 기능은 준비 중입니다.')));
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

  void _toggleCategoryExpansion() {
    setState(() {
      _isCategoryExpanded = !_isCategoryExpanded;
    });
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _isCategoryExpanded = false;
    });
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
          ),
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
            IconButton(
              icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showPreview = !_showPreview;
                });
              },
            ),
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // 카테고리 선택 버튼
                    InkWell(
                      onTap: _toggleCategoryExpansion,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '구분: $_selectedCategory',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Icon(
                              _isCategoryExpanded
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 제목 입력
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _titleController,
                        enableIMEPersonalizedLearning: false,
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

                    // 내용 입력 또는 미리보기
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _showPreview
                            ? SingleChildScrollView(
                                child: Markdown(
                                  data: _contentController.text.isEmpty
                                      ? '내용을 입력하세요...'
                                      : _contentController.text,
                                  selectable: true,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                ),
                              )
                            : TextField(
                                controller: _contentController,
                                enableIMEPersonalizedLearning: false,
                                onChanged: (_) => setState(() {}),
                                maxLines: null,
                                expands: true,
                                textAlignVertical: TextAlignVertical.top,
                                decoration: const InputDecoration(
                                  hintText: '내용을 입력하세요... (Markdown 문법 지원)',
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
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
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

                    // 하단 바 (Markdown 도구 모음)
                    if (!_showPreview)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            // 굵게
                            IconButton(
                              icon: const Icon(Icons.format_bold),
                              tooltip: '굵게',
                              onPressed: () =>
                                  _applyMarkdown('**', suffix: '**'),
                            ),
                            // 기울이기
                            IconButton(
                              icon: const Icon(Icons.format_italic),
                              tooltip: '기울이기',
                              onPressed: () => _applyMarkdown('*', suffix: '*'),
                            ),
                            // 밑줄
                            IconButton(
                              icon: const Icon(Icons.format_underline),
                              tooltip: '밑줄',
                              onPressed: () =>
                                  _applyMarkdown('<u>', suffix: '</u>'),
                            ),
                            // 제목
                            IconButton(
                              icon: const Icon(Icons.title, size: 28),
                              tooltip: '제목',
                              onPressed: _showHeadingMenu,
                            ),
                            // 리스트
                            IconButton(
                              icon: const Icon(Icons.format_list_bulleted),
                              tooltip: '리스트',
                              onPressed: () =>
                                  _applyMarkdown('- ', perLine: true),
                            ),
                            const Spacer(),
                            // 사진 첨부
                            IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
                              tooltip: '사진 첨부',
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey[300]!),
                          ),
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

                // 카테고리 선택 오버레이
                if (_isCategoryExpanded)
                  Positioned(
                    top: 48,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 8,
                      color: Colors.white,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: Text(
                                '일일퀘스트',
                                style: TextStyle(
                                  fontWeight: _selectedCategory == '일일퀘스트'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              onTap: () => _selectCategory('일일퀘스트'),
                            ),
                            ListTile(
                              title: Text(
                                '주간퀘스트',
                                style: TextStyle(
                                  fontWeight: _selectedCategory == '주간퀘스트'
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              onTap: () => _selectCategory('주간퀘스트'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
