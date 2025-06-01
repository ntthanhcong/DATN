import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_upload_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;

  const EditProfileScreen({super.key, required this.username});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final cccdController = TextEditingController();
  String phone = '';
  String birth = '';
  String selectedGender = 'nam';
  String? avatarUrl;
  File? newAvatar;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      emailController.text = data['email'] ?? '';
      cccdController.text = data['cccd'] ?? '';
      phone = data['phone'] ?? '';
      birth = data['birth'] ?? '';
      selectedGender = data['sex'] ?? 'nam';
      avatarUrl = data['avtUrl'] ?? '';
      setState(() {});
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => newAvatar = File(picked.path));
    }
  }

  Future<void> _updateProfile() async {
    setState(() => isLoading = true);

    String? uploadedUrl = avatarUrl;
    if (newAvatar != null) {
      final url = await ImageUploadService.uploadImage(newAvatar!);
      if (url != null) uploadedUrl = url;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .update({
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'cccd': cccdController.text.trim(),
      'sex': selectedGender,
      'avtUrl': uploadedUrl,
    });

    if (mounted) {
      setState(() => isLoading = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Cập nhật thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        backgroundColor: Colors.red,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: newAvatar != null
                              ? FileImage(newAvatar!)
                              : (avatarUrl != null && avatarUrl!.isNotEmpty)
                                  ? NetworkImage(avatarUrl!) as ImageProvider
                                  : null,
                          backgroundColor: Colors.red[200],
                          child: (avatarUrl == null || avatarUrl!.isEmpty)
                              ? const Icon(Icons.person,
                                  size: 60, color: Colors.white)
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _pickAvatar,
                            child: const CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.red, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Điện thoại
                  buildRowLabel("Điện thoại", phone, editable: false),

                  buildDivider(),

                  // Họ tên
                  buildRowEditable("Họ và tên ", nameController),

                  buildDivider(),

                  // Email
                  buildRowEditable("Email", emailController),

                  buildDivider(),

                  // Giới tính
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Giới tính",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'nam',
                            groupValue: selectedGender,
                            onChanged: (val) =>
                                setState(() => selectedGender = val!),
                          ),
                          const Text("Nam"),
                          Radio<String>(
                            value: 'nữ',
                            groupValue: selectedGender,
                            onChanged: (val) =>
                                setState(() => selectedGender = val!),
                          ),
                          const Text("Nữ"),
                        ],
                      )
                    ],
                  ),

                  buildDivider(),

                  // Ngày sinh
                  buildRowLabel("Ngày sinh", birth, editable: false),

                  buildDivider(),

                  // CCCD
                  buildRowEditable("CCCD", cccdController),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child:
                        const Text("Cập nhật", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
    );
  }

  Widget buildDivider() => const Divider(height: 28);

  Widget buildRowLabel(String label, String value, {bool editable = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                color: editable ? Colors.black : Colors.grey[800])),
      ],
    );
  }

  Widget buildRowEditable(String label, TextEditingController controller) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500))),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
