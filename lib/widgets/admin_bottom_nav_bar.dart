import 'package:booking_app/screens/admin/admin_notification_screen.dart';
import 'package:booking_app/screens/admin/admin_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:booking_app/screens/admin/admin_overview.dart';
import 'package:booking_app/screens/admin/admin_manage_config.dart';
import 'package:booking_app/screens/admin/admin_chat_screen.dart';

class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const AdminOverviewScreen();
        break;
      case 1:
        destination = AdminManageConfigScreen();
        break;
      case 2:
        destination = AdminNotificationScreen();
        break;
      case 3:
        destination = AdminProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Cấu hình',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Thông báo',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Tài Khoản',
        ),
      ],
    );
  }
}
