import 'package:booking_app/screens/user/momo_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../edit_user_info_screen.dart';
import 'select_seat_screen.dart';

class ConfirmPickupScreen extends StatefulWidget {
  final String username;
  final String from;
  final String to;
  final String tripType;
  final DateTime travelDate;
  final List<String> seats;
  final int seatPrice;

  const ConfirmPickupScreen({
    super.key,
    required this.username,
    required this.from,
    required this.to,
    required this.tripType,
    required this.travelDate,
    required this.seats,
    required this.seatPrice,
  });

  @override
  State<ConfirmPickupScreen> createState() => _ConfirmPickupScreenState();
}

class _ConfirmPickupScreenState extends State<ConfirmPickupScreen> {
  String? fullName;
  String? phone;
  String? email;
  final pickupController = TextEditingController();
  final dropoffController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.username)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        fullName = data['name'] ?? '';
        phone = data['phone'] ?? '';
        email = data['email'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final travelDateText =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(widget.travelDate);
    final seat = widget.seats.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.from} → ${widget.to}'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thông tin hành khách',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditUserInfoScreen(username: widget.username),
                      ),
                    ).then((result) {
                      if (result != null && result is Map) {
                        setState(() {
                          fullName = result['name'];
                          phone = result['phone'];
                          email = result['email'];
                        });
                      }
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 8),
            infoRow('Họ và tên', fullName ?? ''),
            infoRow('Số điện thoại', phone ?? ''),
            infoRow('Email', email ?? ''),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ghế của bạn', style: TextStyle(color: Colors.grey)),
                IconButton(
                  icon: const Icon(Icons.event_seat, color: Colors.orange),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectSeatScreen(
                          from: widget.from,
                          to: widget.to,
                          tripType: widget.tripType,
                          travelDate: widget.travelDate,
                          username: widget.username,
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
            Text(seat,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(thickness: 1),
            const SizedBox(height: 16),
            const Text('Thông tin đón trả',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Điểm đón'),
            TextField(
              controller: pickupController,
              decoration:
                  const InputDecoration(hintText: 'Nhập địa điểm đón cụ thể'),
            ),
            const SizedBox(height: 12),
            const Text('Điểm trả'),
            TextField(
              controller: dropoffController,
              decoration:
                  const InputDecoration(hintText: 'Nhập địa điểm trả cụ thể'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Quý khách vui lòng kiểm tra đúng số điện thoại để trước 10g sáng ngày ${DateFormat('dd/MM/yyyy').format(widget.travelDate)} tổng đài sẽ liên hệ để kiểm tra thông tin hành khách!',
                  style: const TextStyle(fontSize: 13, color: Colors.red),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MomoPaymentScreen(
                            username: widget.username,
                            fullName: fullName ?? '',
                            phone: phone ?? '',
                            email: email ?? '',
                            from: widget.from,
                            to: widget.to,
                            travelDate: widget.travelDate,
                            seats: widget.seats,
                            pickup: pickupController.text,
                            dropoff: dropoffController.text,
                            seatPrice: widget.seatPrice,
                            tripType: widget.tripType,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child:
                        const Text("Tiếp tục", style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
