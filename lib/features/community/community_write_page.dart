import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../common/constants.dart';
import '../../services/api_service.dart';

class CommunityWritePage extends StatefulWidget {
  final int userQuestId;

  const CommunityWritePage({super.key, required this.userQuestId});

  @override
  State<CommunityWritePage> createState() => _CommunityWritePageState();
}

class _CommunityWritePageState extends State<CommunityWritePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _showPreview = false;

  bool get _hasContent {
    return _titleController.text.isNotEmpty ||
        _contentController.text.isNotEmpty;
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

    print('[DEBUG] 게시글 작성 시작 - userQuestId: ${widget.userQuestId}');
    print('[DEBUG] 제목: ${_titleController.text}');
    print('[DEBUG] 내용: ${_contentController.text}');

    try {
      final response = await ApiService.post(
        '/api/consent-request/COMMUNITY/${widget.userQuestId}',
        body: {
          'title': _titleController.text,
          'content': _contentController.text,
        },
      );

      print('[DEBUG] API 응답 - success: ${response.success}');
      print('[DEBUG] API 응답 - statusCode: ${response.statusCode}');
      print('[DEBUG] API 응답 - data: ${response.data}');
      print('[DEBUG] API 응답 - error: ${response.error}');
      print('[DEBUG] API 응답 - message: ${response.message}');

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('게시글이 작성되었습니다.')));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(
                response.message?.toString() ??
                    response.error?.toString() ??
                    '게시글 작성에 실패했습니다.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('[DEBUG] 예외 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
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
          title: const Text('글쓰기'),
          actions: [
            IconButton(
              icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
              onPressed: () {
                setState(() {
                  _showPreview = !_showPreview;
                });
              },
            ),
            TextButton(
              onPressed: _publishPost,
              child: const Text(
                '등록',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
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
      ),
    );
  }
}
