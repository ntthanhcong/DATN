import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ManageTripScreen extends StatefulWidget {
  const ManageTripScreen({super.key});

  @override
  State<ManageTripScreen> createState() => _ManageTripScreenState();
}

class _ManageTripScreenState extends State<ManageTripScreen> {
  String tripType = 'Chuyến đi';
  DateTime? selectedDate;
  List<String> bookedSeats = [];
  Map<String, dynamic> seatDetails = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 30)),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchBookedSeats(); // Call after selecting date
    }
  }

  Future<void> fetchBookedSeats() async {
    if (selectedDate == null) return;

    final startOfDay =
        DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('tripType', isEqualTo: tripType)
          .where('travelDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('travelDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      List<String> allBooked = [];
      Map<String, dynamic> seatData = {};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        List<dynamic> seats = data['selectedSeats'] ?? [];

        for (var seat in seats) {
          allBooked.add(seat);
          seatData[seat] = {
            'username': data['username'] ?? '',
            // Không có 'tripCode', nên có thể bỏ hoặc thay thế
            'phone': data['phone'] ?? '',
            'message': data['noteMessage'] ?? '',
            'fromLocation': data['fromLocation'] ?? '',
            'fromAddress': data['pickup'] ?? '',
            'toLocation': data['toLocation'] ?? '',
            'toAddress': data['dropoff'] ?? '',
            'tripType': data['tripType'] ?? '',
          };
        }
      }
      setState(() {
        bookedSeats = allBooked;
        seatDetails = seatData;
      });
    } catch (e) {
      debugPrint("❌ Lỗi khi truy vấn vé đã đặt: $e");
    }
  }

  void viewBookingDetails(String seatCode) {
    final d = seatDetails[seatCode];
    if (d == null) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Chi tiết vé - Ghế $seatCode",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              _infoRow("👤 Họ tên", d['username']),
              _infoRow("📞 SĐT", d['phone']),
              _infoRow(
                  "🚩 Điểm đi", "${d['fromAddress']} , ${d['fromLocation']}"),
              _infoRow("🏁 Điểm đến", "${d['toAddress']} , ${d['toLocation']}"),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Đóng"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildSeat(String code) {
    final isBooked = bookedSeats.contains(code);
    final color = isBooked ? Colors.red : Colors.grey[300];

    return GestureDetector(
      onTap: isBooked ? () => viewBookingDetails(code) : null,
      child: Container(
        margin: const EdgeInsets.all(3),
        width: 38,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          code,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
      ),
    );
  }

  Widget _buildSeatLayout() {
    List<String> aLeft = ['A1D', 'A2D', 'A3D', 'A4D', 'A5D', 'A6D'];
    List<String> aRight = ['A1T', 'A2T', 'A3T', 'A4T', 'A5T', 'A6T'];
    List<String> bLeft = ['B1D', 'B2D', 'B3D', 'B4D', 'B5D', 'B6D'];
    List<String> bRight = ['B1T', 'B2T', 'B3T', 'B4T', 'B5T', 'B6T'];
    List<String> cLeft = ['C1D', 'C2D', 'C3D', 'C4D', 'C5D', 'C6D'];
    List<String> cRight = ['C1T', 'C2T', 'C3T', 'C4T', 'C5T', 'C6T'];
    List<String> d1 = ['D1D', 'D2D', 'D3D', 'D4D', 'D5D'];
    List<String> d2 = ['D1T', 'D2T', 'D3T', 'D4T', 'D5T'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(children: aLeft.map(_buildSeat).toList()),
            const SizedBox(width: 4),
            Column(children: aRight.map(_buildSeat).toList()),
            const SizedBox(width: 10),
            Column(children: bLeft.map(_buildSeat).toList()),
            const SizedBox(width: 4),
            Column(children: bRight.map(_buildSeat).toList()),
            const SizedBox(width: 10),
            Column(children: cLeft.map(_buildSeat).toList()),
            const SizedBox(width: 4),
            Column(children: cRight.map(_buildSeat).toList()),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 6, children: d1.map(_buildSeat).toList()),
        Wrap(spacing: 6, children: d2.map(_buildSeat).toList()),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.square, color: Colors.red, size: 14),
            SizedBox(width: 4),
            Text("Ghế đã đặt"),
            SizedBox(width: 12),
            Icon(Icons.square_outlined, size: 14),
            SizedBox(width: 4),
            Text("Ghế trống"),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatted = selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(selectedDate!)
        : 'Chưa chọn';

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý chuyến xe")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Chọn chuyến và ngày", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: tripType,
              onChanged: (v) => setState(() => tripType = v!),
              items: ['Chuyến đi', 'Chuyến về']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
            ElevatedButton(
              onPressed: _pickDate,
              child: Text("Ngày đi: $formatted"),
            ),
            const SizedBox(height: 20),
            if (selectedDate != null) _buildSeatLayout(),
          ],
        ),
      ),
    );
  }
}
