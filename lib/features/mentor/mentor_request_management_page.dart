import 'package:flutter/material.dart';
import '../../common/constants.dart';
import '../../services/api_service.dart';

class MentorRequestManagementPage extends StatefulWidget {
  const MentorRequestManagementPage({super.key});

  @override
  State<MentorRequestManagementPage> createState() =>
      _MentorRequestManagementPageState();
}

class _MentorRequestManagementPageState
    extends State<MentorRequestManagementPage> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;
  bool _hasAccepted = false; // 수락 여부 추적

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final response = await ApiService.get('/api/user/mentor-request/mentor');

      if (mounted) {
        if (response.success && response.data != null) {
          // response.data가 List인지 확인
          final dataList = response.data is List ? response.data as List : [];

          setState(() {
            _requests = List<Map<String, dynamic>>.from(
              dataList
                  .where((req) {
                    // PENDING 상태인 요청만 필터링
                    final status = req['status']?.toString() ?? 'PENDING';
                    return status == 'PENDING';
                  })
                  .map(
                    (req) => {
                      'id': req['mentorRequestId'],
                      'menteeUsername': req['mentee']?['username'] ?? '알 수 없음',
                      'status': req['status']?.toString() ?? 'PENDING',
                      'createdAt': req['createdAt'] ?? '',
                    },
                  ),
            );
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('요청 목록을 불러오는데 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _handleRequest(int requestId, bool accept) async {
    setState(() => _isLoading = true);

    try {
      final endpoint = accept
          ? '/api/user/mentor-request/accept/$requestId'
          : '/api/user/mentor-request/reject/$requestId';

      final response = await ApiService.put(endpoint);

      if (mounted) {
        if (response.success) {
          // 수락한 경우 플래그 설정
          if (accept) {
            _hasAccepted = true;
          }

          // 로컬 상태 업데이트 - 서버에서 다시 불러오지 않음
          setState(() {
            final index = _requests.indexWhere((req) => req['id'] == requestId);
            if (index != -1) {
              _requests[index]['status'] = accept ? 'ACCEPTED' : 'REJECTED';
            }
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(accept ? '요청을 수락했습니다.' : '요청을 거절했습니다.')),
          );
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message ?? '요청 처리에 실패했습니다.')),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return '대기중';
      case 'ACCEPTED':
        return '수락됨';
      case 'REJECTED':
        return '거절됨';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.of(context).pop(_hasAccepted);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
          ),
          title: const Text('멘토 요청 관리'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(_hasAccepted);
            },
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _requests.isEmpty
              ? const Center(
                  child: Text(
                    '받은 멘토 요청이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    final status = request['status']?.toString() ?? 'PENDING';
                    final isPending = status == 'PENDING';
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(child: Icon(Icons.person)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request['menteeUsername'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            request['status'],
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          _getStatusText(request['status']),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(
                                              request['status'],
                                            ),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (isPending) ...[
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _handleRequest(request['id'], true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('수락'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _handleRequest(request['id'], false),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('거절'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
