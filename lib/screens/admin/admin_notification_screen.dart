import 'package:booking_app/screens/admin/add_notification_screen.dart';
import 'package:booking_app/screens/admin/admin_notification_detail_screen.dart';
import 'package:booking_app/screens/admin/admin_chat_screen.dart';
import 'package:booking_app/widgets/admin_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminNotificationScreen extends StatefulWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  State<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState extends State<AdminNotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget buildNotificationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text(
                  data['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: data['createdAt'] != null
                    ? Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(
                          (data['createdAt'] as Timestamp).toDate(),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminNotificationDetailScreen(
                        docId: doc.id,
                        title: data['title'] ?? '',
                        content: data['content'] ?? '',
                        imageUrl: data['imageUrl'],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Thông Báo & Tin Nhắn'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Thông Báo"),
            Tab(text: "Tin Nhắn"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildNotificationList(),
          const AdminChatScreen(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddNotificationScreen()),
                );
              },
              child: const Icon(Icons.add),
              tooltip: 'Thêm Thông Báo',
            )
          : null,
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 2),
    );
  }
}
