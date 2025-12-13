import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../services/api_service.dart';

class RemoveMenteePage extends StatefulWidget {
  const RemoveMenteePage({super.key});

  @override
  State<RemoveMenteePage> createState() => _RemoveMenteePageState();
}

class _RemoveMenteePageState extends State<RemoveMenteePage> {
  List<Map<String, dynamic>> _mentees = [];
  bool _isLoading = true;
  bool _hasDeleted = false; // 삭제 여부 추적

  @override
  void initState() {
    super.initState();
    _loadMentees();
  }

  Future<void> _loadMentees() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.get('/api/user/mentee');

      if (mounted) {
        if (response.success && response.data != null) {
          // response.data가 List인지 확인
          final dataList = response.data is List ? response.data as List : [];

          setState(() {
            _mentees = List<Map<String, dynamic>>.from(
              dataList.map((mentee) {
                return {
                  'userId': mentee['userId'],
                  'username': mentee['username'] ?? '알 수 없음',
                  'level': mentee['level'] ?? 1,
                  'exp': mentee['exp'] ?? 0,
                };
              }),
            );
            _isLoading = false;
          });
        } else {
          setState(() {
            _mentees = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mentees = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('멘티 목록을 불러오는데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmDialog(Map<String, dynamic> mentee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('멘티 삭제'),
        content: Text(
          '정말로 ${mentee['username']}님과의 관계를 삭제하시겠습니까?\n\n'
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
      await _deleteMentee(mentee['userId']);
    }
  }

  Future<void> _deleteMentee(int menteeId) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.delete('/api/user/mentee/$menteeId');

      if (mounted) {
        if (response.success) {
          _hasDeleted = true;
          await _loadMentees();
          setState(() => _isLoading = false);

          if (!mounted) return;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('삭제 완료'),
              content: const Text('멘티 관계가 성공적으로 삭제되었습니다.'),
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
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? '멘티 삭제에 실패했습니다.')),
          );
        }
      }
    } on FormatException {
      // 204 No Content 응답의 경우 파싱 에러가 발생할 수 있지만 삭제는 성공
      if (mounted) {
        _hasDeleted = true;
        await _loadMentees();
        setState(() => _isLoading = false);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('삭제 완료'),
            content: const Text('멘티 관계가 성공적으로 삭제되었습니다.'),
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

  Future<void> _showDeleteAllConfirmDialog() async {
    if (_mentees.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전체 멘티 삭제'),
        content: Text(
          '정말로 모든 멘티(${_mentees.length}명)와의 관계를 삭제하시겠습니까?\n\n'
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
            child: const Text('전체 삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAllMentees();
    }
  }

  Future<void> _deleteAllMentees() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.delete('/api/user/mentee');

      if (mounted) {
        if (response.success) {
          _hasDeleted = true;
          await _loadMentees();
          setState(() => _isLoading = false);

          if (!mounted) return;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('삭제 완료'),
              content: const Text('모든 멘티 관계가 성공적으로 삭제되었습니다.'),
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
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? '전체 멘티 삭제에 실패했습니다.')),
          );
        }
      }
    } on FormatException {
      // 204 No Content 응답의 경우 파싱 에러가 발생할 수 있지만 삭제는 성공
      if (mounted) {
        _hasDeleted = true;
        await _loadMentees();
        setState(() => _isLoading = false);

        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('삭제 완료'),
            content: const Text('모든 멘티 관계가 성공적으로 삭제되었습니다.'),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasDeleted);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
          ),
          title: const Text('멘티 삭제'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_hasDeleted);
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadMentees,
              tooltip: '새로고침',
            ),
            if (_mentees.isNotEmpty)
              TextButton(
                onPressed: _showDeleteAllConfirmDialog,
                child: const Text(
                  '전체 삭제',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _mentees.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '현재 멘티가 없습니다.',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMentees,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
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
                                '멘티를 삭제하면 관계가 완전히 끊어지며, 이 작업은 되돌릴 수 없습니다.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _mentees.length,
                          itemBuilder: (context, index) {
                            final mentee = _mentees[index];

                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16.0),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  mentee['username'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Level ${mentee['level']} • EXP ${mentee['exp']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmDialog(mentee),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
