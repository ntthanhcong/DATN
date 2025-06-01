import 'package:flutter/material.dart';
import '../screens/user/home_screen.dart';
import '../screens/booking_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/history_screen.dart';
import '../screens/user/notification_screen.dart'; // 👈 Import thêm

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String username;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.username,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = HomeScreen(username: username);
        break;
      case 1:
        destination = HistoryScreen(username: username);
        break;
      case 2:
        destination = NotificationScreen(username: username);
        break;
      case 3:
        destination = ProfileScreen(username: username);
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
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications), label: 'Thông báo'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
      ],
    );
  }
}
