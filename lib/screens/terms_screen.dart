import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Điều khoản & Dịch vụ")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            "1. Bạn đồng ý không sử dụng ứng dụng vào mục đích sai trái...\n"
            "2. Tất cả dữ liệu người dùng sẽ được bảo mật...\n"
            "3. Chính sách quyền riêng tư được cập nhật định kỳ...\n\n"
            "Vui lòng đọc kỹ trước khi sử dụng dịch vụ.",
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
