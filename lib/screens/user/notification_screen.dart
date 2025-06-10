import 'package:booking_app/widgets/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'notification_detail_screen.dart';
import 'user_chat_screen.dart';

class NotificationScreen extends StatelessWidget {
  final String username;

  const NotificationScreen({super.key, required this.username});

  void _openNotificationDetail(
      BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationDetailScreen(
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Không có thông báo."));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final formattedTime =
                DateFormat('dd/MM/yyyy – HH:mm').format(createdAt);

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                title: Text(data['title'] ?? 'Thông báo',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  formattedTime,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openNotificationDetail(context, data),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trung tâm thông báo"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Thông báo"),
              Tab(text: "Tin nhắn"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNotificationList(),
            UserChatScreen(username: username),
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: 2, // đúng với vị trí "Thông báo"
          username: username,
        ),
      ),
    );
  }
}
