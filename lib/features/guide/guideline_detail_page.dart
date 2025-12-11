import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../common/constants.dart';
import '../../models/guideline_post_model.dart';

class GuidelineDetailPage extends StatefulWidget {
  final GuidelinePost post;

  const GuidelineDetailPage({super.key, required this.post});

  @override
  State<GuidelineDetailPage> createState() => _GuidelineDetailPageState();
}

class _GuidelineDetailPageState extends State<GuidelineDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('가이드라인 상세'),
      ),
      body: SafeArea(
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

              // 퀘스트 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoChip(
                          Icons.star,
                          '난이도',
                          widget.post.difficulty,
                          Colors.amber,
                        ),
                        _buildInfoChip(
                          Icons.emoji_events,
                          'EXP',
                          '${widget.post.expReward}',
                          Colors.orange,
                        ),
                        _buildInfoChip(
                          Icons.military_tech,
                          '필요 레벨',
                          'Lv.${widget.post.levelRequired}',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),

              // 내용 (Markdown 렌더링)
              MarkdownBody(
                data: widget.post.description,
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
