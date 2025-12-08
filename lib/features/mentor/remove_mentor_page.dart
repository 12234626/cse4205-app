import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../services/api_service.dart';

class RemoveMentorPage extends StatefulWidget {
  const RemoveMentorPage({super.key});

  @override
  State<RemoveMentorPage> createState() => _RemoveMentorPageState();
}

class _RemoveMentorPageState extends State<RemoveMentorPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _mentorInfo;

  @override
  void initState() {
    super.initState();
    _loadMentorInfo();
  }

  Future<void> _loadMentorInfo() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('/api/user/mentor');

      if (mounted) {
        if (response.success && response.data != null) {
          setState(() {
            _mentorInfo = {
              'userId': response.data['userId'],
              'username': response.data['username'] ?? '알 수 없음',
              'level': response.data['level'] ?? 1,
              'exp': response.data['exp'] ?? 0,
            };
            _isLoading = false;
          });
        } else {
          setState(() {
            _mentorInfo = null;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mentorInfo = null;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('멘토 정보를 불러오는데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멘토 삭제'),
        content: Text(
          '정말로 ${_mentorInfo?['username'] ?? '멘토'}님과의 관계를 삭제하시겠습니까?\n\n'
          '이 작업은 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteMentor();
    }
  }

  Future<void> _deleteMentor() async {
    setState(() => _isLoading = true);

    try {
      // 먼저 멘토 정보가 실제로 있는지 확인
      final checkResponse = await ApiService.get('/api/user/mentor');

      if (!checkResponse.success || checkResponse.data == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('삭제할 멘토가 없습니다.')));
        }
        return;
      }

      // 멘토가 있으면 삭제 진행
      final response = await ApiService.delete('/api/user/mentor');

      if (mounted) {
        if (response.success) {
          setState(() => _isLoading = false);

          if (!mounted) return;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('삭제 완료'),
              content: const Text('멘토 관계가 성공적으로 삭제되었습니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('확인'),
                ),
              ],
            ),
          );

          if (!mounted) return;
          Navigator.of(context).pop(true);
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? '멘토 삭제에 실패했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('멘토 삭제'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMentorInfo,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mentorInfo == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '현재 멘토가 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '현재 멘토',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '멘토와의 관계를 삭제할 수 있습니다.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 30,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mentorInfo!['username'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level ${_mentorInfo!['level']} • EXP ${_mentorInfo!['exp']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_outlined,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '주의사항',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 멘토를 삭제하면 관계가 완전히 끊어집니다.\n'
                          '• 이 작업은 되돌릴 수 없습니다.\n'
                          '• 다시 멘토를 추가하려면 새로운 요청을 보내야 합니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _showDeleteConfirmDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '멘토 삭제',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
