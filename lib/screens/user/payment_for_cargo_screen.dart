// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:booking_app/services/cargo_service.dart';

class PaymentForCargoScreen extends StatefulWidget {
  final String username;
  final String from;
  final String to;
  final String tripType;
  final DateTime travelDate;
  final String cargoType;
  final String cargoUnit;
  final int cargoPricePerUnit;
  final int quantity;
  final String pickupAddress;
  final String dropoffAddress;

  const PaymentForCargoScreen({
    Key? key,
    required this.username,
    required this.from,
    required this.to,
    required this.tripType,
    required this.travelDate,
    required this.cargoType,
    required this.cargoUnit,
    required this.cargoPricePerUnit,
    required this.quantity,
    required this.pickupAddress,
    required this.dropoffAddress,
  }) : super(key: key);

  @override
  State<PaymentForCargoScreen> createState() => _PaymentForCargoScreenState();
}

class _PaymentForCargoScreenState extends State<PaymentForCargoScreen> {
  String fullName = "";
  String phone = "";
  String email = "";
  bool _loading = false;
  bool _handled = false;
  late StreamSubscription<String?> _linkSub;

  int get totalAmount => widget.cargoPricePerUnit * widget.quantity;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _linkSub = linkStream.listen((String? link) {
      if (link != null && link.contains("mymomoapp://payment-result")) {
        _handleUri(Uri.parse(link));
      }
    });
  }

  @override
  void dispose() {
    _linkSub.cancel();
    super.dispose();
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

  Future<void> _handleUri(Uri uri) async {
    if (_handled) return;
    _handled = true;

    final resultCode = uri.queryParameters['resultCode'];
    final orderId = uri.queryParameters['orderId'] ?? DateTime.now().toString();

    if (resultCode == '0') {
      final cargoService = CargoService();
      await cargoService.saveCargoOrder(
        username: widget.username,
        fullName: fullName,
        phone: phone,
        email: email,
        from: widget.from,
        to: widget.to,
        travelDate: widget.travelDate,
        cargoType: widget.cargoType,
        cargoUnit: widget.cargoUnit,
        quantity: widget.quantity,
        pricePerUnit: widget.cargoPricePerUnit,
        pickupAddress: widget.pickupAddress,
        dropoffAddress: widget.dropoffAddress,
        orderId: orderId,
        tripType: widget.tripType,
      );

      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Gửi hàng thành công!')),
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
          "orderInfo": "Thanh toán gửi hàng cho ${widget.username}",
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

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.from} → ${widget.to}"),
        backgroundColor: Colors.green,
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
                    const Text("Thông tin gửi hàng",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    infoRow("Loại hàng", widget.cargoType),
                    infoRow(
                        "Số lượng", "${widget.quantity} ${widget.cargoUnit}"),
                    infoRow("Đơn giá",
                        "${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(widget.cargoPricePerUnit)} / ${widget.cargoUnit}"),
                    infoRow("Điểm lấy hàng",
                        "${widget.pickupAddress}, ${widget.from}"),
                    infoRow("Điểm giao hàng",
                        "${widget.dropoffAddress}, ${widget.to}"),
                    infoRow("Ngày gửi", formattedDate),
                  ],
                ),
              ),
            ),
            const Text(
              "Vui lòng đảm bảo thông tin hàng hóa và liên hệ chính xác để tránh thất lạc!",
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
                    const Text("Thông tin người gửi",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    infoRow("Họ và tên", fullName),
                    infoRow("Số điện thoại", phone),
                    infoRow("Email", email),
                  ],
                ),
              ),
            ),
            const Text("Lưu ý: Vui lòng kiểm tra lại toàn bộ thông tin.",
                style: TextStyle(color: Colors.red, fontSize: 13)),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    infoRow("Đơn giá",
                        "${widget.cargoPricePerUnit}đ x ${widget.quantity} ${widget.cargoUnit}"),
                    infoRow("Phí thanh toán", "0đ"),
                    infoRow("Tổng thanh toán",
                        "${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalAmount)}"),
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
                    backgroundColor: Colors.green,
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
