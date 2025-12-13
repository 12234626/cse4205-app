import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../models/guideline_post_model.dart';
import '../../services/api_service.dart';
import 'guideline_detail_page.dart';

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

    try {
      final response = await ApiService.get('/api/quest');

      // debugPrint(
      //   '[가이드라인] API 응답: success=${response.success}, data=${response.data}',
      // );

      if (response.success && response.data != null) {
        final List<GuidelinePost> posts = [];
        final questList = response.data as List;

        // debugPrint('[가이드라인] 전체 퀘스트 개수: ${questList.length}');

        for (var questData in questList) {
          // debugPrint(
          //   '[가이드라인] 퀘스트 확인: category=${questData['category']}, questType=${questData['questType']}, title=${questData['title']}',
          // );

          // category가 "GUIDELINE"이고 questType이 "NORMAL"인 퀸스트만 필터링
          if (questData['category'] == 'GUIDELINE' &&
              questData['questType'] == 'NORMAL') {
            // debugPrint('[가이드라인] ✅ 필터 통과: ${questData['title']}');
            try {
              posts.add(GuidelinePost.fromJson(questData));
            } catch (e) {
              debugPrint('가이드라인 파싱 오류: $e');
            }
          }
        }

        // debugPrint('[가이드라인] 필터링 후 개수: ${posts.length}');

        // questId 기준 오름차순 정렬
        posts.sort((a, b) => a.questId.compareTo(b.questId));

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message?.toString() ?? '가이드라인을 불러오지 못했습니다.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
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
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadPosts,
                child: _posts.isEmpty
                    ? const Center(
                        child: Text(
                          '아직 가이드라인이 없습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _posts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                      ),
              ),
      ),
    );
  }

  Widget _buildPostCard(GuidelinePost post) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuidelineDetailPage(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // 내용 미리보기
              Text(
                _getPreviewText(post.description),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // 난이도 및 보상 정보
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    post.difficulty,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.emoji_events, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${post.expReward} EXP',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.military_tech, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Lv.${post.levelRequired}+',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
