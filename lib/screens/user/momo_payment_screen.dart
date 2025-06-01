import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:booking_app/services/ticket_service.dart';

class MomoPaymentScreen extends StatefulWidget {
  final String username;
  final String fullName;
  final String phone;
  final String email;
  final String from;
  final String to;
  final DateTime travelDate;
  final List<String> seats;
  final String pickup;
  final String dropoff;
  final int seatPrice;
  final String tripType;

  const MomoPaymentScreen({
    super.key,
    required this.username,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.from,
    required this.to,
    required this.travelDate,
    required this.seats,
    required this.pickup,
    required this.dropoff,
    required this.seatPrice,
    required this.tripType,
  });

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  StreamSubscription<String?>? _linkSub;
  bool _handled = false;
  bool _loading = false;
  int totalAmount = 0;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.seatPrice * widget.seats.length;
    _linkSub = linkStream.listen((String? link) {
      if (link != null && link.contains("mymomoapp://payment-result")) {
        _handleUri(Uri.parse(link));
      }
    });
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _handleUri(Uri uri) async {
    if (_handled) return;
    _handled = true;

    final resultCode = uri.queryParameters['resultCode'];
    final orderId = uri.queryParameters['orderId'] ?? DateTime.now().toString();

    if (resultCode == '0') {
      final ticketService = TicketService();
      await ticketService.savePassengerTicket(
        username: widget.username,
        fullName: widget.fullName,
        phone: widget.phone,
        email: widget.email,
        from: widget.from,
        to: widget.to,
        travelDate: widget.travelDate,
        seats: widget.seats,
        pickup: widget.pickup,
        dropoff: widget.dropoff,
        orderId: orderId,
        totalAmount: totalAmount,
        tripType: widget.tripType,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Thanh toán thành công!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Thanh toán thất bại.')),
      );
    }
  }

  Future<void> _payWithMoMo() async {
    setState(() => _loading = true);
    final uri = Uri.parse("http://10.0.2.2:3000/create-payment");

    try {
      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "amount": totalAmount.toString(),
          "orderInfo": "Thanh toán vé xe cho ${widget.username}",
          "redirectUrl": "mymomoapp://payment-result",
          "ipnUrl": "https://webhook.site/your-id"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final payUrl = data['payUrl'] as String?;
        if (payUrl != null && payUrl.isNotEmpty) {
          final url = Uri.parse(payUrl);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            _showError("Không thể mở trang MoMo");
          }
        }
      } else {
        _showError("Lỗi tạo thanh toán: ${response.body}");
      }
    } catch (e) {
      _showError("Lỗi kết nối tới server: $e");
    }

    setState(() => _loading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700])),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${widget.travelDate.day.toString().padLeft(2, '0')}/${widget.travelDate.month.toString().padLeft(2, '0')}/${widget.travelDate.year}";
    final seats = widget.seats.join(', ');

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.from} → ${widget.to}"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin lượt đi",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    infoRow("Tuyến xe", "${widget.from} - ${widget.to}"),
                    infoRow("Thời gian khởi hành", formattedDate),
                    infoRow("Số lượng vé", "${widget.seats.length} vé"),
                    infoRow("Vị trí ghế", seats),
                    infoRow("Điểm đón", "${widget.pickup}, ${widget.from}"),
                    infoRow("Điểm trả", "${widget.dropoff}, ${widget.to}"),
                  ],
                ),
              ),
            ),
            const Text(
              "Quý khách vui lòng có mặt tại Điểm đón trước giờ khởi hành để nhà xe kịp thời xử lý mọi tình huống!",
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Thông tin thanh toán",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    infoRow("Họ và tên", widget.fullName),
                    infoRow("Số điện thoại", widget.phone),
                    infoRow("Email", widget.email),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            const Text("Lưu ý: Vui lòng kiểm tra lại toàn bộ thông tin.",
                style: TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    infoRow("Giá vé",
                        "${widget.seatPrice}đ x ${widget.seats.length} vé"),
                    infoRow("Phí thanh toán", "0đ"),
                    infoRow("Tổng thanh toán", "$totalAmount đ"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _payWithMoMo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Thanh toán",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
