import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUserScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hiển thị danh sách người dùng từ Firestore
  void _confirmDeleteUser(
      BuildContext context, String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
              'Bạn có chắc chắn muốn xóa người dùng "$userName" khỏi hệ thống?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Đóng hộp thoại
                await deleteUser(context, userId, userName);
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý người dùng')),
      body: StreamBuilder(
        stream: _firestore.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: ListTile(
                  title: Text(
                      user['username']), // Hiển thị username (tên đăng nhập)
                  subtitle:
                      Text('Họ tên: ${user['name']}'), // Hiển thị name (họ tên)
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút chỉnh sửa người dùng
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditDialog(context, user.id,
                              user.data() as Map<String, dynamic>);
                        },
                      ),
                      // Nút xóa người dùng
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDeleteUser(context, user.id, user['name']);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    _showUserDetailsDialog(
                        context,
                        user.data() as Map<String,
                            dynamic>); // Hiển thị chi tiết người dùng
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Hộp thoại chỉnh sửa thông tin người dùng
  void _showEditDialog(
      BuildContext context, String userId, Map<String, dynamic> userData) {
    final TextEditingController usernameController = TextEditingController(
        text: userData['username']); // Tên đăng nhập (username)
    final TextEditingController phoneController =
        TextEditingController(text: userData['phone']);
    final TextEditingController emailController =
        TextEditingController(text: userData['email']); // Email
    final TextEditingController fullNameController =
        TextEditingController(text: userData['name']); // Họ tên (name)

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa người dùng'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                    controller: usernameController,
                    decoration: InputDecoration(labelText: 'Tên đăng nhập')),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Số điện thoại')),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email')), // Email
                TextField(
                    controller: fullNameController,
                    decoration: InputDecoration(
                        labelText: 'Họ và tên')), // Họ tên (name)
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                // Cập nhật người dùng với thông tin sửa đổi
                Map<String, dynamic> updatedData = {
                  'username': usernameController.text, // Tên đăng nhập
                  'phone': phoneController.text,
                  'email': emailController.text, // Cập nhật email
                  'name': fullNameController.text, // Cập nhật họ và tên (name)
                };
                await updateUser(context, userId, updatedData);
                Navigator.of(context).pop();
              },
              child: Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Hiển thị chi tiết người dùng
  void _showUserDetailsDialog(
      BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chi tiết người dùng'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  "Tên đăng nhập: ${userData['username']}"), // Hiển thị username (tên đăng nhập)
              Text("Số điện thoại: ${userData['phone']}"),
              Text("Email: ${userData['email']}"), // Hiển thị email
              Text(
                  "Họ và tên: ${userData['name']}"), // Hiển thị họ và tên (name)
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  // Cập nhật thông tin người dùng vào Firestore
  Future<void> updateUser(BuildContext context, String userId,
      Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật người dùng thành công')),
      );
    } catch (e) {
      print('Lỗi cập nhật người dùng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi cập nhật: $e')),
      );
    }
  }

  // Xóa người dùng
  Future<void> deleteUser(
      BuildContext context, String userId, String userName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ Đã xóa "$userName" khỏi hệ thống'),
        ),
      );
    } catch (e) {
      print('Lỗi xóa người dùng: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi khi xóa: $e')),
      );
    }
  }
}
