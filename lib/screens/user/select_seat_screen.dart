import 'package:booking_app/screens/user/confirm_pickup_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectSeatScreen extends StatefulWidget {
  final String from;
  final String to;
  final String tripType;
  final DateTime travelDate;
  final String username;

  const SelectSeatScreen({
    super.key,
    required this.from,
    required this.to,
    required this.tripType,
    required this.travelDate,
    required this.username,
  });

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  List<String> selectedSeats = [];
  List<String> bookedSeats = [];
  int seatPrice = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSeatPrice();
    fetchBookedSeats();
  }

  Future<void> fetchSeatPrice() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('pricing')
          .get();

      if (doc.exists) {
        final data = doc.data();
        final price = data?['seatPrice'];

        if (price is int || price is double) {
          setState(() {
            seatPrice = (price as num).toInt();
          });
        }
      }
    } catch (_) {}
    setState(() => isLoading = false);
  }

  Future<void> fetchBookedSeats() async {
    try {
      final startOfDay = DateTime(widget.travelDate.year,
          widget.travelDate.month, widget.travelDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('tickets')
          .where('tripType', isEqualTo: widget.tripType)
          .where('travelDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('travelDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      final List<String> booked = [];
      for (var doc in snapshot.docs) {
        final seats = doc['selectedSeats'];
        if (seats is List) {
          booked.addAll(seats.cast<String>());
        }
      }

      setState(() => bookedSeats = booked);
    } catch (e) {
      debugPrint("Lỗi khi lấy ghế đã đặt: $e");
    }
  }

  void toggleSeat(String seat) {
    if (bookedSeats.contains(seat)) return;
    setState(() {
      if (selectedSeats.contains(seat)) {
        selectedSeats.remove(seat);
      } else {
        selectedSeats.add(seat);
      }
    });
  }

  Widget buildSeat(String seatCode) {
    Color color;
    if (bookedSeats.contains(seatCode)) {
      color = Colors.red;
    } else if (selectedSeats.contains(seatCode)) {
      color = Colors.green;
    } else {
      color = Colors.white;
    }

    return GestureDetector(
      onTap: () => toggleSeat(seatCode),
      child: Container(
        width: 42,
        height: 38,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          seatCode,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color:
                bookedSeats.contains(seatCode) ? Colors.black54 : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildSeatColumn(List<String> seats) {
    return Column(children: seats.map(buildSeat).toList());
  }

  Widget buildSeatLayout() {
    List<String> aD = ['A1D', 'A2D', 'A3D', 'A4D', 'A5D', 'A6D'];
    List<String> aT = ['A1T', 'A2T', 'A3T', 'A4T', 'A5T', 'A6T'];
    List<String> bD = ['B1D', 'B2D', 'B3D', 'B4D', 'B5D', 'B6D'];
    List<String> bT = ['B1T', 'B2T', 'B3T', 'B4T', 'B5T', 'B6T'];
    List<String> cD = ['C1D', 'C2D', 'C3D', 'C4D', 'C5D', 'C6D'];
    List<String> cT = ['C1T', 'C2T', 'C3T', 'C4T', 'C5T', 'C6T'];
    List<String> dRow1 = ['D1D', 'D2D', 'D3D', 'D4D', 'D5D'];
    List<String> dRow2 = ['D1T', 'D2T', 'D3T', 'D4T', 'D5T'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildSeatColumn(aD),
            buildSeatColumn(aT),
            const SizedBox(width: 24),
            buildSeatColumn(bD),
            buildSeatColumn(bT),
            const SizedBox(width: 24),
            buildSeatColumn(cD),
            buildSeatColumn(cT),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dRow1.map(buildSeat).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: dRow2.map(buildSeat).toList(),
        ),
        const SizedBox(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.square, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text("Ghế đã chọn   "),
            Icon(Icons.square_outlined, size: 16),
            SizedBox(width: 4),
            Text("Ghế trống   "),
            Icon(Icons.square, color: Colors.red, size: 16),
            SizedBox(width: 4),
            Text("Ghế đã đặt"),
          ],
        ),
        const SizedBox(height: 4),
        const Text("T: Trên, D: Dưới",
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final formattedDate =
        DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(widget.travelDate);
    final totalPrice = selectedSeats.length * seatPrice;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.from} → ${widget.to}'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      const Text("Ngày đi",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('08:30 $formattedDate'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildSeatLayout(),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${widget.tripType}: ${selectedSeats.length} vé",
                    style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  "Số tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(totalPrice)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedSeats.isEmpty
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfirmPickupScreen(
                                  from: widget.from,
                                  to: widget.to,
                                  tripType: widget.tripType,
                                  travelDate: widget.travelDate,
                                  seats: selectedSeats,
                                  username: widget.username,
                                  seatPrice: seatPrice,
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
          ),
        ],
      ),
    );
  }
}
