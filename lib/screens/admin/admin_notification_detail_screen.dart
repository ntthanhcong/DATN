import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'add_notification_screen.dart'; // import màn hình sửa

class AdminNotificationDetailScreen extends StatelessWidget {
  final String docId;
  final String title;
  final String content;
  final String? imageUrl;

  const AdminNotificationDetailScreen({
    super.key,
    required this.docId,
    required this.title,
    required this.content,
    this.imageUrl,
  });

  Future<void> deleteNotification(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa thông báo này không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Đã xóa thông báo')),
      );
      Navigator.pop(context); // Trở về màn hình quản lý
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Thông báo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 100),
                ),
              ),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Xóa'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => deleteNotification(context),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Sửa'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddNotificationScreen(
                          isEdit: true,
                          docId: docId,
                          initialTitle: title,
                          initialContent: content,
                          imageUrl: imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
