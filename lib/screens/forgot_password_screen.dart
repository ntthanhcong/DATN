import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;
  bool isLoading = false;

  void showSnack(String msg, {Color? backgroundColor, IconData? icon}) {
    final color = backgroundColor ?? Colors.black87;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
  }

  Future<void> handleSendOTP() async {
    final rawPhone = phoneController.text.trim();

    // Kiểm tra định dạng số điện thoại
    final regex = RegExp(r'^0[0-9]{9,10}$');
    if (!regex.hasMatch(rawPhone)) {
      showSnack("⚠️ Số điện thoại không hợp lệ. Vui lòng nhập đúng định dạng!");
      return;
    }

    final phone =
        '+84' + rawPhone.substring(1); // chuyển 0xxxxxxx -> +84xxxxxxxx

    setState(() => isLoading = true);

    // Kiểm tra số điện thoại đã tồn tại
    final exists = await _authService.checkPhoneExists(phone);
    if (!exists) {
      setState(() => isLoading = false);
      showSnack("❌ Số điện thoại chưa được đăng ký!");
      return;
    }

    // Gửi OTP
    final error = await _authService.sendPasswordResetOTP(phone);
    setState(() {
      isLoading = false;
      otpSent = error == null;
    });

    if (otpSent) {
      showSnack("✅ Mã OTP đã được gửi!");
    } else {
      showSnack("❌ Gửi OTP thất bại: $error");
    }
  }

  Future<void> handleVerifyOTP() async {
    final success =
        await _authService.verifyPasswordOTP(otpController.text.trim());
    if (success) {
      setState(() => otpVerified = true);
      showSnack("✅ Xác minh OTP thành công!");
    } else {
      showSnack("❌ Mã OTP không hợp lệ!");
    }
  }

  Future<void> handleResetPassword() async {
    final phone = phoneController.text.trim();
    final newPassword = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      showSnack("❌ Mật khẩu xác nhận không khớp!");
      return;
    }

    final success = await _authService.resetPassword(phone, newPassword);
    if (success) {
      showSnack("🔐 Đặt lại mật khẩu thành công!");
      Navigator.pop(context);
    } else {
      showSnack("❌ Không tìm thấy tài khoản với số điện thoại này!");
    }
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {bool isPassword = false, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon) : null,
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quên mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTextField("Số điện thoại", phoneController,
                        icon: Icons.phone),
                    ElevatedButton(
                      onPressed: handleSendOTP,
                      child: const Text("Gửi OTP"),
                    ),
                    if (otpSent) ...[
                      _buildTextField("Mã OTP", otpController,
                          icon: Icons.message),
                      ElevatedButton(
                        onPressed: handleVerifyOTP,
                        child: const Text("Xác minh OTP"),
                      ),
                    ],
                    if (otpVerified) ...[
                      _buildTextField("Mật khẩu mới", passwordController,
                          isPassword: true, icon: Icons.lock),
                      _buildTextField(
                          "Xác nhận mật khẩu", confirmPasswordController,
                          isPassword: true, icon: Icons.lock_outline),
                      ElevatedButton(
                        onPressed: handleResetPassword,
                        child: const Text("Đặt lại mật khẩu"),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
