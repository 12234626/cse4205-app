import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../common/constants.dart';

class CommunityWritePage extends StatefulWidget {
  const CommunityWritePage({super.key});

  @override
  State<CommunityWritePage> createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;
  bool _showPreview = true;

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
      // 각 줄마다 적용
      final lines = selectedText.split('\n');
      final modifiedLines = lines
          .map((line) {
            if (line.trim().isEmpty) return line;
            return '$prefix$line';
          })
          .join('\n');
      newText = modifiedLines;
    } else {
      // 전체 선택 영역에 적용
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

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해주세요')));
      return;
    }

    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('내용을 입력해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);

    // TODO: 실제 API 호출
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('게시글이 작성되었습니다')));

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('게시글 작성'),
        actions: [
          IconButton(
            icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
            onPressed: () {
              setState(() {
                _showPreview = !_showPreview;
              });
            },
          ),
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitPost,
              child: const Text(
                '완료',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 입력
                  TextField(
                    controller: _titleController,
                    enableIMEPersonalizedLearning: false,
                    decoration: InputDecoration(
                      hintText: '제목을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),

                  // 내용 입력 또는 미리보기
                  if (_showPreview)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(minHeight: 400),
                      child: Markdown(
                        data: _contentController.text.isEmpty
                            ? '내용을 입력하세요'
                            : _contentController.text,
                        selectable: true,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    )
                  else
                    TextField(
                      controller: _contentController,
                      enableIMEPersonalizedLearning: false,
                      decoration: InputDecoration(
                        hintText: '내용을 입력하세요 (Markdown 문법 지원)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        alignLabelWithHint: true,
                      ),
                      style: const TextStyle(fontSize: 16),
                      maxLines: 15,
                      maxLength: 2000,
                    ),
                ],
              ),
            ),
          ),

          // Markdown 도구 모음
          if (!_showPreview)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  // 굵게
                  IconButton(
                    icon: const Icon(Icons.format_bold),
                    tooltip: '굵게',
                    onPressed: () => _applyMarkdown('**', suffix: '**'),
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
                    onPressed: () => _applyMarkdown('<u>', suffix: '</u>'),
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
                    onPressed: () => _applyMarkdown('- ', perLine: true),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
