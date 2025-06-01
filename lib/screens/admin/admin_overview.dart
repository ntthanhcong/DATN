import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'manage_ticket_screen.dart';
import 'manage_user_screen.dart';
import 'manage_trip_screen.dart';
import '../../widgets/admin_bottom_nav_bar.dart'; // Đảm bảo bạn đã thêm Navbar

class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Tổng quan hôm nay"),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCard(
              icon: Icons.receipt_long,
              title: "Vé đã đặt",
              subtitleStream: _todayTicketCountStream(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageTicketScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              icon: Icons.directions_bus,
              title: "Chi tiết chuyến xe",
              subtitle: "Xem & quản lý chuyến xe",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageTripScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _buildCard(
              icon: Icons.people,
              title: "Người dùng",
              subtitleStream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots()
                  .map((snap) => "${snap.docs.length} người dùng"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ManageUserScreen()),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavBar(
        currentIndex: 0,
      ), // Đảm bảo AdminBottomNavBar hoạt động
    );
  }

  Stream<String> _todayTicketCountStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('tickets')
        .where('travelDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('travelDate', isLessThan: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => "${snap.docs.length} vé hôm nay");
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Stream<String>? subtitleStream,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5, // Thêm hiệu ứng bóng cho card
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1),
          radius: 25,
          child: Icon(icon, color: Colors.orange, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitleStream != null
            ? StreamBuilder<String>(
                stream: subtitleStream,
                builder: (context, snapshot) {
                  return Text(snapshot.data ?? "Đang tải...");
                },
              )
            : Text(subtitle ?? ""),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
