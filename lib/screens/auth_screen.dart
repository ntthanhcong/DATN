import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../services/auth_service.dart';
import '../screens/admin/admin_overview.dart';
import '../screens/user/home_screen.dart';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();

  // Controllers
  final loginUsernameController = TextEditingController();
  final loginPasswordController = TextEditingController();

  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final birthController = TextEditingController();

  bool isOTPSent = false;
  bool isOTPVerified = false;
  bool acceptedTerms = false;
  String? currentPhone;
  String? selectedGender;
  String normalizePhone(String raw) {
    return '+84' + raw.trim().replaceFirst(RegExp(r'^0'), '');
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> loginUser() async {
    final username = loginUsernameController.text.trim();
    final password = loginPasswordController.text.trim();

    final user = await _authService.loginWithUsername(username, password);
    if (user == null) {
      showSnack("❌ Sai tên đăng nhập hoặc mật khẩu");
      return;
    }

    if (user.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminOverviewScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: user.username)),
      );
    }
  }

  Future<void> sendOTP() async {
    final rawPhone = phoneController.text.trim();
    currentPhone = rawPhone;

    final error = await _authService.sendOTP(rawPhone, forRegistration: true);
    if (error == null) {
      setState(() => isOTPSent = true);
      showSnack("✅ Đã gửi mã OTP");
    } else {
      showSnack("❌ Lỗi gửi OTP: $error");
    }
  }

  Future<void> verifyOTP() async {
    final otp = otpController.text.trim();
    final verified = await _authService.verifyOTP(otp);
    if (verified) {
      setState(() => isOTPVerified = true);
      showSnack("✅ Xác minh OTP thành công!");
    } else {
      showSnack("❌ Mã OTP không chính xác");
    }
  }

  Future<void> registerUser() async {
    if (!isOTPVerified) {
      showSnack("⚠️ Vui lòng xác minh OTP trước");
      return;
    }
    if (!acceptedTerms) {
      showSnack("⚠️ Bạn cần chấp nhận điều kiện sử dụng để đăng ký");
      return;
    }
    if (usernameController.text.trim().isEmpty ||
        nameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        birthController.text.trim().isEmpty ||
        selectedGender == null) {
      showSnack("⚠️ Vui lòng nhập đầy đủ tất cả thông tin");
      return;
    }

    final newUser = UserModel(
      id: usernameController.text.trim(),
      username: usernameController.text.trim(),
      name: nameController.text.trim(),
      email: "", // không yêu cầu
      phone: normalizePhone(phoneController.text.trim()),
      password: passwordController.text.trim(),
      birth: birthController.text.trim(),
      sex: selectedGender ?? '',
      role: 'user',
      cccd: "", // không yêu cầu
      avtUrl: "", // không yêu cầu
    );

    final String? error = await _authService.registerUser(newUser);
    if (error == null) {
      showSnack("🎉 Đăng ký thành công!");
      _tabController.animateTo(0);
    } else {
      showSnack("❌ $error");
    }
  }

  Widget _buildTextField(
      String hint, IconData icon, TextEditingController controller,
      {bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
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

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
              "Tên tài khoản", Icons.person, loginUsernameController),
          _buildTextField("Mật khẩu", Icons.lock, loginPasswordController,
              isPassword: true),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loginUser,
            child: const Text("Đăng nhập"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: const StadiumBorder(),
              backgroundColor: Colors.blue,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/forgot_password'),
            child: const Text("Quên mật khẩu?",
                style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField(
              "Tên tài khoản", Icons.account_circle, usernameController),
          _buildTextField("Họ và tên", Icons.person, nameController),
          Row(
            children: [
              const Icon(Icons.wc, color: Colors.grey),
              const SizedBox(width: 8),
              const Text("Giới tính:"),
              const SizedBox(width: 12),
              Row(
                children: [
                  Radio<String>(
                    value: 'nam',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const Text("Nam"),
                  const SizedBox(width: 8),
                  Radio<String>(
                    value: 'nữ',
                    groupValue: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                  ),
                  const Text("Nữ"),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                locale: const Locale('vi', 'VN'),
              );
              if (picked != null) {
                setState(() {
                  birthController.text =
                      DateFormat('dd/MM/yyyy').format(picked);
                });
              }
            },
            child: AbsorbPointer(
              child: _buildTextField("Ngày sinh", Icons.cake, birthController),
            ),
          ),
          _buildTextField("Mật khẩu", Icons.lock, passwordController,
              isPassword: true),
          _buildTextField("Số điện thoại", Icons.phone, phoneController),
          if (!isOTPSent)
            ElevatedButton(
              onPressed: sendOTP,
              child: const Text("Gửi OTP"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                shape: const StadiumBorder(),
              ),
            ),
          if (isOTPSent && !isOTPVerified) ...[
            _buildTextField("Mã OTP", Icons.message, otpController),
            ElevatedButton(
              onPressed: verifyOTP,
              child: const Text("Xác minh OTP"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: const StadiumBorder(),
              ),
            ),
          ],
          const SizedBox(height: 8),
          CheckboxListTile(
            value: acceptedTerms,
            onChanged: (val) => setState(() => acceptedTerms = val ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero, // bỏ padding để sát viền hơn
            title: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text("Tôi đồng ý với "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/terms');
                  },
                  child: const Text(
                    "Điều khoản & Dịch vụ sử dụng",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: registerUser,
            child: const Text("Đăng ký"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: const StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset("assets/logo.png", height: 90),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: "Đăng nhập"),
                Tab(text: "Đăng ký"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildLoginTab(),
                  _buildRegisterTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
