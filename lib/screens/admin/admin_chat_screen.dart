import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../services/image_upload_service.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final String adminId = "admin";
  final picker = ImagePicker();

  String? selectedUser;
  String get chatId => selectedUser != null ? "${selectedUser}_$adminId" : '';

  void sendMessage({String? imageUrl}) async {
    final text = _controller.text.trim();
    if (text.isEmpty && imageUrl == null) return;

    final data = {
      'senderId': adminId,
      'username': 'admin',
      'text': text,
      'timestamp': Timestamp.now(),
    };

    if (imageUrl != null) {
      data['imageUrl'] = imageUrl;
    }

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(data);

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [selectedUser, adminId],
      'lastMessage': text.isNotEmpty ? text : '[Hình ảnh]',
      'updatedAt': Timestamp.now(),
    }, SetOptions(merge: true));

    _controller.clear();
  }

  Future<void> pickAndSendImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final url = await ImageUploadService.uploadImage(File(picked.path));
      if (url != null) {
        sendMessage(imageUrl: url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedUser == null
          ? _buildUserList()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final data =
                              messages[index].data() as Map<String, dynamic>;
                          final isMe = data['senderId'] == adminId;

                          final timestamp = data['timestamp'] as Timestamp;
                          final timeStr =
                              DateFormat('HH:mm').format(timestamp.toDate());

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.red : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data['imageUrl'] != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data['imageUrl'],
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Text('⚠ Lỗi ảnh'),
                                      ),
                                    ),
                                  if ((data['text'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        data['text'],
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      timeStr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMe
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: pickAndSendImage,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: "Nhập tin nhắn...",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => sendMessage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('chats').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final chats = snapshot.data!.docs;

        final users = chats.map((doc) {
          final usersList = (doc['users'] as List).cast<String>();
          return usersList.firstWhere((u) => u != adminId,
              orElse: () => 'unknown');
        }).toList();

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final username = users[index];
            return ListTile(
              title: Text(username),
              trailing: const Icon(Icons.chat),
              onTap: () {
                setState(() {
                  selectedUser = username;
                });
              },
            );
          },
        );
      },
    );
  }
}
