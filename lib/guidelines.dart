import 'package:flutter/material.dart';
import 'constants.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('가이드라인 : 분리수거'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGuidelineCard(
            context,
            title: '일일퀘스트 : 분리수거',
            content: '테스트 내용입니다.',
            date: '2025-01-18',
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard(
    BuildContext context, {
    required String title,
    required String content,
    required String date,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // 게시글 상세보기
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuidelineDetailPage(
                title: title,
                content: content,
                date: date,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GuidelineDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String date;

  const GuidelineDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('가이드라인 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(date, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const Divider(height: 32),
            // 분리수거 게시글에만 이미지 표시
            if (title.contains('분리수거'))
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
