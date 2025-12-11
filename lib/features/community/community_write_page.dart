import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
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
  final List<XFile> _selectedImages = []; // 선택된 이미지 파일 목록 (로컬)
  bool _isSubmitting = false; // 게시글 등록 중 상태

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImages.add(pickedFile);
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지가 추가되었습니다.')));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImagesToS3() async {
    final List<String> uploadedUrls = [];

    for (final imageFile in _selectedImages) {
      try {
        // 1단계: Presigned URL 받기
        final fileName = imageFile.name;
        final contentType = 'image/${imageFile.path.split('.').last}';

        final presignedResponse = await ApiService.post(
          '/api/upload/presigned-url',
          body: {
            'fileName': fileName,
            'contentType': contentType,
            'folder': 'community',
          },
        );

        if (!presignedResponse.success || presignedResponse.data == null) {
          throw Exception('Presigned URL 생성 실패');
        }

        final uploadUrl = presignedResponse.data['uploadUrl'];
        final fileUrl = presignedResponse.data['fileUrl'];

        // 2단계: S3에 이미지 업로드
        final file = File(imageFile.path);
        final bytes = await file.readAsBytes();

        final uploadResponse = await http.put(
          Uri.parse(uploadUrl),
          headers: {'Content-Type': contentType},
          body: bytes,
        );

        if (uploadResponse.statusCode != 200) {
          throw Exception('이미지 업로드 실패');
        }

        uploadedUrls.add(fileUrl);
      } catch (e) {
        debugPrint('[DEBUG] 이미지 업로드 오류: $e');
        rethrow;
      }
    }

    return uploadedUrls;
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

    setState(() => _isSubmitting = true);

    debugPrint('[DEBUG] 게시글 작성 시작 - userQuestId: ${widget.userQuestId}');
    debugPrint('[DEBUG] 제목: ${_titleController.text}');
    debugPrint('[DEBUG] 내용: ${_contentController.text}');
    debugPrint('[DEBUG] 이미지 개수: ${_selectedImages.length}');

    try {
      // 1단계: 이미지가 있으면 S3에 업로드
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        debugPrint('[DEBUG] 이미지 업로드 시작...');
        uploadedImageUrls = await _uploadImagesToS3();
        debugPrint('[DEBUG] 이미지 업로드 완료: $uploadedImageUrls');
      }

      // 2단계: 게시글 작성
      final response = await ApiService.post(
        '/api/consent-request/COMMUNITY/${widget.userQuestId}',
        body: {
          'title': _titleController.text,
          'content': _contentController.text,
        },
      );

      debugPrint('[DEBUG] API 응답 - success: ${response.success}');
      debugPrint('[DEBUG] API 응답 - statusCode: ${response.statusCode}');
      debugPrint('[DEBUG] API 응답 - data: ${response.data}');
      debugPrint('[DEBUG] API 응답 - error: ${response.error}');
      debugPrint('[DEBUG] API 응답 - message: ${response.message}');

      // 3단계: 이미지가 있으면 DB에 저장
      if (response.success && uploadedImageUrls.isNotEmpty) {
        final consentRequestId = response.data['consentRequestId'];
        debugPrint(
          '[DEBUG] 이미지 DB 저장 시작 - consentRequestId: $consentRequestId',
        );

        for (final imageUrl in uploadedImageUrls) {
          await ApiService.post(
            '/api/upload/save-file',
            body: {
              'fileUrl': imageUrl,
              'fileType': 'CONSENT_IMAGE',
              'consentRequestId': consentRequestId,
            },
          );
        }
        debugPrint('[DEBUG] 이미지 DB 저장 완료');
      }

      if (mounted) {
        if (response.success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('게시글이 작성되었습니다.')));
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
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
      debugPrint('[DEBUG] 예외 발생: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
            _isSubmitting
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : TextButton(
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

            // 이미지 미리보기
            if (_selectedImages.isNotEmpty)
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImages[index].path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

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
                    const Spacer(),
                    // 이미지 추가
                    IconButton(
                      icon: const Icon(Icons.image),
                      tooltip: '이미지 추가',
                      onPressed: _pickImage,
                      color: AppColors.primary,
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
