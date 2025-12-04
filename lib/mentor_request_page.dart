import 'package:flutter/material.dart';
import 'constants.dart';
import 'services/api_service.dart';

class MentorRequestPage extends StatefulWidget {
  const MentorRequestPage({super.key});

  @override
  State<MentorRequestPage> createState() => _MentorRequestPageState();
}

class _MentorRequestPageState extends State<MentorRequestPage> {
  final TextEditingController _mentorUsernameController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mentorUsernameController.dispose();
    super.dispose();
  }

  Future<void> _sendMentorRequest() async {
    final mentorUsername = _mentorUsernameController.text.trim();

    if (mentorUsername.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('멘토 닉네임을 입력해주세요.')));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1단계: 닉네임으로 사용자 프로필 조회
      final profileResponse = await ApiService.get(
        '/api/user/profile/username/$mentorUsername',
      );

      if (!mounted) return;

      if (!profileResponse.success || profileResponse.data == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '해당 닉네임의 사용자를 찾을 수 없습니다.';
        });
        return;
      }

      // 멘토 정보 추출
      final mentorData = profileResponse.data;

      // userId 필드명 확인 (id 또는 userId)
      final mentorId = mentorData['userId'] ?? mentorData['id'];
      final mentorRole = mentorData['role'];

      if (mentorId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = '사용자 정보를 가져올 수 없습니다.';
        });
        return;
      }

      // 멘토 역할 확인
      if (mentorRole != 'mentor') {
        setState(() {
          _isLoading = false;
          _errorMessage = '해당 사용자는 멘토가 아닙니다.';
        });
        return;
      }

      // 2단계: 멘토 ID로 요청 전송
      final requestResponse = await ApiService.post(
        '/api/user/mentor-request',
        body: {'mentorId': mentorId},
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (requestResponse.success) {
        setState(() {
          _errorMessage = null;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('멘토 요청이 전송되었습니다.')));
        _mentorUsernameController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(requestResponse.message ?? '멘토 요청 전송에 실패했습니다.'),
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
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.appBarGradient),
        ),
        title: const Text('멘토 요청'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '멘토 추가',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '멘토의 닉네임을 입력하여 요청을 보내세요.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _mentorUsernameController,
              decoration: InputDecoration(
                labelText: '멘토 닉네임',
                hintText: '멘토 닉네임을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (value) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null;
                  });
                }
              },
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendMentorRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        '멘토 요청 보내기',
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
