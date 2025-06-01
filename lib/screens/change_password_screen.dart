import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String username;

  const ChangePasswordScreen({super.key, required this.username});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPass = TextEditingController();
  final newPass = TextEditingController();
  final confirmPass = TextEditingController();

  bool isLoading = false;

  Future<void> _updatePassword() async {
    final old = oldPass.text.trim();
    final newPwd = newPass.text.trim();
    final confirm = confirmPass.text.trim();

    if (newPwd != confirm) {
      _showSnackBar("❌ Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() => isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .get();

    final currentPwd = doc['password'];

    if (currentPwd != old) {
      _showSnackBar("❌ Mật khẩu hiện tại không đúng");
      setState(() => isLoading = false);
      return;
    }

    if (!_isPasswordValid(newPwd)) {
      _showSnackBar("❌ Mật khẩu mới không đủ mạnh");
      setState(() => isLoading = false);
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .update({'password': newPwd});

    setState(() => isLoading = false);
    _showSnackBar("✅ Cập nhật mật khẩu thành công");

    oldPass.clear();
    newPass.clear();
    confirmPass.clear();
  }

  bool _isPasswordValid(String password) {
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final badWords = ['password', '1234', 'admin', 'welcome'];
    final noBadWords = !badWords.any((word) => password.contains(word));
    return password.length >= 8 &&
        hasUpper &&
        hasLower &&
        hasDigit &&
        noBadWords;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            passwordField("Mật khẩu cũ", oldPass),
            const SizedBox(height: 12),
            passwordField("Mật khẩu mới", newPass),
            const SizedBox(height: 12),
            passwordField("Nhập lại mật khẩu mới", confirmPass),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Lưu ý:",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ...[
              "1. Tối thiểu 8 ký tự",
              "2. Ít nhất 1 chữ cái viết hoa",
              "3. Ít nhất 1 chữ cái thường",
              "4. Ít nhất 1 chữ số",
              "5. Không chứa cụm từ dễ đoán như password, 1234, admin, welcome..."
            ].map((e) => Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text("• $e", style: const TextStyle(color: Colors.red)),
                )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : _updatePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading ? Colors.grey : Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Cập nhật"),
            ),
          ],
        ),
      ),
    );
  }

  Widget passwordField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.visibility),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
