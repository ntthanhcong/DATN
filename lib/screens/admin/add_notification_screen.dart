import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNotificationScreen extends StatefulWidget {
  final bool isEdit;
  final String? docId;
  final String? initialTitle;
  final String? initialContent;
  final String? imageUrl;

  const AddNotificationScreen({
    super.key,
    this.isEdit = false,
    this.docId,
    this.initialTitle,
    this.initialContent,
    this.imageUrl,
  });

  @override
  State<AddNotificationScreen> createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  XFile? _pickedImage;
  bool _isLoading = false;
  String? _imageUrl;

  final String imgbbApiKey = '6ecfa1a0ba42a85550bc2762d42ffd5e';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
    _imageUrl = widget.imageUrl;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _pickedImage = pickedFile);
    }
  }

  Future<String?> uploadToImgbb(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      final url = Uri.parse('https://api.imgbb.com/1/upload?key=$imgbbApiKey');
      final response = await http.post(url, body: {
        'image': base64Image,
        'name': imageFile.name,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      }
    } catch (e) {
      print('Upload error: $e');
    }
    return null;
  }

  Future<void> submitNotification() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung')),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? finalImageUrl = _imageUrl;
    if (_pickedImage != null) {
      final uploaded = await uploadToImgbb(_pickedImage!);
      if (uploaded != null) finalImageUrl = uploaded;
    }

    final Map<String, dynamic> data = {
      'title': _titleController.text,
      'content': _contentController.text,
      'imageUrl': finalImageUrl,
    };

    if (widget.isEdit && widget.docId != null) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(widget.docId)
          .update(data);
    } else {
      data['createdAt'] = Timestamp.now();
      await FirebaseFirestore.instance.collection('notifications').add(data);
    }

    setState(() => _isLoading = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.isEdit
              ? '✅ Đã cập nhật thông báo'
              : '✅ Đã tạo thông báo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Sửa Thông Báo' : 'Thêm Thông Báo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tiêu đề'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Nội dung'),
            ),
            const SizedBox(height: 12),
            _pickedImage != null
                ? Image.file(File(_pickedImage!.path), height: 150)
                : (_imageUrl != null
                    ? Image.network(_imageUrl!, height: 150)
                    : const Text('Chưa chọn ảnh')),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Chọn ảnh'),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: submitNotification,
                    icon: const Icon(Icons.send),
                    label: Text(widget.isEdit ? 'Cập nhật' : 'Tạo Thông Báo'),
                  ),
          ],
        ),
      ),
    );
  }
}
