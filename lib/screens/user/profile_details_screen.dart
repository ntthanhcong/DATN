import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final String username;

  const ProfileDetailsScreen({super.key, required this.username});

  Future<Map<String, dynamic>?> _fetchUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return const Center(
                child: Text("Không tìm thấy thông tin người dùng."));
          }

          final avtUrl = data['avtUrl'] ?? '';
          final name = data['name'] ?? '';
          final phone = data['phone'] ?? '';

          return SingleChildScrollView(
            child: Column(
              children: [
                // Avatar + Họ tên + SĐT
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      ClipOval(
                        child: avtUrl.isNotEmpty
                            ? Image.network(
                                avtUrl,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.red[100],
                                  width: 90,
                                  height: 90,
                                  child: const Icon(Icons.person,
                                      color: Colors.white, size: 40),
                                ),
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: Colors.red[100],
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 40),
                              ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Thông tin cá nhân (chia card nhẹ từng ô)
                _buildInfoTile("Họ và tên", data['name']),
                _buildInfoTile("Số điện thoại", data['phone']),
                _buildInfoTile("Email", data['email']),
                _buildInfoTile("Giới tính", data['sex'] ?? "Chưa cập nhật"),
                _buildInfoTile("Ngày sinh", data['birth'] ?? "Chưa cập nhật"),
                _buildInfoTile("CCCD", data['cccd'] ?? "Chưa cập nhật"),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/edit_profile',
                                arguments: username);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text("Cập nhật thông tin"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/change_password',
                                arguments: username);
                          },
                          icon: const Icon(Icons.lock_outline),
                          label: const Text("Đổi mật khẩu"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
              child:
                  Text(title, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 12),
          Text(value ?? "",
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
