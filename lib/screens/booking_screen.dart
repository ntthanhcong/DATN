// import 'package:booking_app/screens/payment_for_cargo_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/booking_info.dart';
// import '../screens/payment_screen.dart';
// import '../widgets/banner_header.dart';
// import '../widgets/bottom_nav_bar.dart';
// import '../services/admin_service.dart';
// import 'dart:async';

// class BookingScreen extends StatefulWidget {
//   final String username;

//   const BookingScreen({super.key, required this.username});

//   @override
//   State<BookingScreen> createState() => _BookingScreenState();
// }

// class _BookingScreenState extends State<BookingScreen> {
//   // Thay vì hardcode, lưu dynamic list ở đây
//   List<String> departureLocations = [];
//   List<String> arrivalLocations = [];

//   // Các state cũ
//   String tripType = 'Chuyến đi';
//   String? selectedFrom;
//   String? selectedTo;
//   String? serviceType;
//   DateTime? selectedDate;

//   final fromDetail = TextEditingController();
//   final toDetail = TextEditingController();
//   final cargoType = TextEditingController();
//   final cargoWeight = TextEditingController();
//   final notePhone = TextEditingController();
//   final noteMessage = TextEditingController();

//   List<String> selectedSeats = [];
//   List<String> bookedSeats = [];

//   final List<String> tripTypes = ['Chuyến đi', 'Chuyến về'];

//   late final AdminService _adminService;
//   late final StreamSubscription<List<LocationModel>> _locSub;

//   @override
//   void initState() {
//     super.initState();
//     // Khởi tạo và lắng nghe stream từ Firestore
//     _adminService = AdminService();
//     _locSub = _adminService.locationsStream().listen((locs) {
//       setState(() {
//         departureLocations = locs
//             .where((l) => l.type == 'departure')
//             .map((l) => l.name)
//             .toList();
//         arrivalLocations =
//             locs.where((l) => l.type == 'arrival').map((l) => l.name).toList();
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _locSub.cancel();
//     super.dispose();
//   }

//   void resetBooking() {
//     setState(() {
//       selectedFrom = null;
//       selectedTo = null;
//       serviceType = null;
//       selectedSeats.clear();
//       fromDetail.clear();
//       toDetail.clear();
//       cargoType.clear();
//       cargoWeight.clear();
//       notePhone.clear();
//       noteMessage.clear();
//       selectedDate = null;
//       bookedSeats.clear();
//     });
//   }

//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final cutoff = DateTime(now.year, now.month, now.day, 7);
//     final DateTime firstDate =
//         now.isAfter(cutoff) ? now.add(Duration(days: 1)) : now;

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: firstDate,
//       firstDate: firstDate,
//       lastDate: now.add(Duration(days: 30)),
//       locale: const Locale('vi', 'VN'),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//         selectedSeats.clear();
//       });
//       fetchBookedSeats();
//     }
//   }

//   void fetchBookedSeats() async {
//     if (selectedDate == null) return;
//     final dateString = DateFormat('dd/MM/yyyy').format(selectedDate!);
//     final snapshot = await FirebaseFirestore.instance
//         .collection('tickets')
//         .where('tripType', isEqualTo: tripType)
//         .where('travelDate', isEqualTo: dateString)
//         .get();

//     List<String> allBooked = [];
//     for (var doc in snapshot.docs) {
//       List<dynamic> seats = doc['selectedSeats'] ?? [];
//       allBooked.addAll(seats.map((e) => e.toString()));
//     }

//     setState(() {
//       bookedSeats = allBooked;
//     });
//   }

//   void toggleSeat(String code) {
//     if (bookedSeats.contains(code)) return;
//     setState(() {
//       if (selectedSeats.contains(code)) {
//         selectedSeats.remove(code);
//       } else {
//         selectedSeats.add(code);
//       }
//     });
//   }

//   Widget _buildSeat(String code) {
//     final isSelected = selectedSeats.contains(code);
//     final isBooked = bookedSeats.contains(code);

//     return Container(
//       margin: const EdgeInsets.all(3),
//       width: 38,
//       height: 30,
//       decoration: BoxDecoration(
//         color: isBooked
//             ? Colors.red
//             : isSelected
//                 ? Colors.green
//                 : Colors.grey[300],
//         border: Border.all(color: Colors.black),
//         borderRadius: BorderRadius.circular(6),
//       ),
//       alignment: Alignment.center,
//       child: GestureDetector(
//         onTap: isBooked ? null : () => toggleSeat(code),
//         child: Text(code,
//             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }

//   Widget _buildSeatLayout() {
//     List<String> aLeft = ['A1D', 'A2D', 'A3D', 'A4D', 'A5D', 'A6D'];
//     List<String> aRight = ['A1T', 'A2T', 'A3T', 'A4T', 'A5T', 'A6T'];
//     List<String> bLeft = ['B1D', 'B2D', 'B3D', 'B4D', 'B5D', 'B6D'];
//     List<String> bRight = ['B1T', 'B2T', 'B3T', 'B4T', 'B5T', 'B6T'];
//     List<String> cLeft = ['C1D', 'C2D', 'C3D', 'C4D', 'C5D', 'C6D'];
//     List<String> cRight = ['C1T', 'C2T', 'C3T', 'C4T', 'C5T', 'C6T'];
//     List<String> dRow1 = ['D1D', 'D2D', 'D3D', 'D4D', 'D5D'];
//     List<String> dRow2 = ['D1T', 'D2T', 'D3T', 'D4T', 'D5T'];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         const Text("🪑 Chọn ghế",
//             style: TextStyle(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Column(children: aLeft.map(_buildSeat).toList()),
//             const SizedBox(width: 6),
//             Column(children: aRight.map(_buildSeat).toList()),
//             const SizedBox(width: 20),
//             Column(children: bLeft.map(_buildSeat).toList()),
//             const SizedBox(width: 6),
//             Column(children: bRight.map(_buildSeat).toList()),
//             const SizedBox(width: 20),
//             Column(children: cLeft.map(_buildSeat).toList()),
//             const SizedBox(width: 6),
//             Column(children: cRight.map(_buildSeat).toList()),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 8,
//           children: dRow1.map(_buildSeat).toList(),
//         ),
//         Wrap(
//           alignment: WrapAlignment.center,
//           spacing: 8,
//           children: dRow2.map(_buildSeat).toList(),
//         ),
//         const SizedBox(height: 10),
//         const Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.square, color: Colors.green, size: 14),
//                 SizedBox(width: 4),
//                 Text("Ghế đã chọn   "),
//                 Icon(Icons.square_outlined, size: 14),
//                 SizedBox(width: 4),
//                 Text("Ghế trống   "),
//                 Icon(Icons.square, color: Colors.red, size: 14),
//                 SizedBox(width: 4),
//                 Text("Ghế đã đặt"),
//               ],
//             ),
//             SizedBox(height: 4),
//             Text(
//               "T: Trên, D: Dưới",
//               style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   void _goToPayment() {
//     final tripCode =
//         "${tripType == 'Chuyến đi' ? 'DK-HUE' : 'HUE-DK'}-${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}";

//     final booking = BookingInfo(
//       username: widget.username,
//       tripCode: tripCode,
//       tripType: tripType,
//       fromLocation: selectedFrom ?? '',
//       fromAddress: fromDetail.text,
//       toLocation: selectedTo ?? '',
//       toAddress: toDetail.text,
//       travelDate: DateFormat('dd/MM/yyyy').format(selectedDate!),
//       selectedSeats: selectedSeats,
//       serviceType: serviceType ?? '',
//       cargoType: cargoType.text,
//       cargoWeight: double.tryParse(cargoWeight.text) ?? 0,
//       notePhone: notePhone.text,
//       noteMessage: noteMessage.text,
//     );

//     if (serviceType == 'Gửi hàng') {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PaymentForCargoScreen(bookingInfo: booking),
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => PaymentScreen(bookingInfo: booking),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // nếu chưa load xong thì hiển thị loading
//     if (departureLocations.isEmpty || arrivalLocations.isEmpty) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     // chọn list from/to tùy tripType
//     final fromList =
//         tripType == 'Chuyến đi' ? departureLocations : arrivalLocations;
//     final toList =
//         tripType == 'Chuyến đi' ? arrivalLocations : departureLocations;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: Colors.pink[50],
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Chọn chuyến
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("🚍 Chọn chuyến",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//               DropdownButton<String>(
//                 value: tripType,
//                 onChanged: (value) {
//                   setState(() {
//                     tripType = value!;
//                     resetBooking();
//                   });
//                 },
//                 items: tripTypes
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),

//           // Dịch vụ
//           const Text("🧾 Loại dịch vụ",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           DropdownButtonFormField<String>(
//             value: serviceType,
//             onChanged: (val) => setState(() => serviceType = val),
//             items:
//                 ['Chở người', 'Gửi hàng'] // Đã loại bỏ "Gửi hàng + Chở người"
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//             decoration: const InputDecoration(hintText: "Chọn dịch vụ"),
//           ),
//           const SizedBox(height: 10),

//           // Điểm đi/đến
//           const Text("🛫 Điểm đi",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           DropdownButtonFormField<String>(
//             value: selectedFrom,
//             onChanged: (val) => setState(() => selectedFrom = val),
//             items: fromList
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             decoration: const InputDecoration(hintText: "Chọn điểm đi"),
//           ),
//           TextField(
//               controller: fromDetail,
//               decoration: const InputDecoration(hintText: "Nhập địa chỉ đón")),

//           const SizedBox(height: 10),
//           const Text("🛬 Điểm đến",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           DropdownButtonFormField<String>(
//             value: selectedTo,
//             onChanged: (val) => setState(() => selectedTo = val),
//             items: toList
//                 .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                 .toList(),
//             decoration: const InputDecoration(hintText: "Chọn điểm đến"),
//           ),
//           TextField(
//               controller: toDetail,
//               decoration: const InputDecoration(hintText: "Nhập địa chỉ đến")),

//           const SizedBox(height: 10),
//           const Text("📅 Ngày đi",
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           ElevatedButton(
//             onPressed: _pickDate,
//             child: Text(selectedDate == null
//                 ? "Chọn ngày đi"
//                 : "Ngày đi: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}"),
//           ),
//           const SizedBox(height: 20),

//           // Hàng hóa
//           if (serviceType == 'Gửi hàng' ||
//               serviceType == 'Gửi hàng + Chở người') ...[
//             const Text("📦 Loại hàng hóa"),
//             TextField(
//                 controller: cargoType,
//                 decoration: const InputDecoration(hintText: "Nhập loại hàng")),
//             const SizedBox(height: 10),
//             const Text("⚖️ Khối lượng (kg)"),
//             TextField(
//                 controller: cargoWeight,
//                 keyboardType: TextInputType.number,
//                 decoration: const InputDecoration(hintText: "Nhập khối lượng")),
//             const SizedBox(height: 20),
//           ],

//           // Ghế
//           if (serviceType == 'Chở người' ||
//               serviceType == 'Gửi hàng + Chở người') ...[
//             _buildSeatLayout(),
//             const SizedBox(height: 20),
//           ],

//           // Ghi chú
//           const Text("📞 Số điện thoại để tổng đài liên hệ"),
//           TextField(
//               controller: notePhone,
//               keyboardType: TextInputType.phone,
//               decoration:
//                   const InputDecoration(hintText: "Nhập số điện thoại")),
//           const SizedBox(height: 10),
//           const Text("📝 Ghi chú thêm cho tổng đài"),
//           TextField(
//               controller: noteMessage,
//               maxLines: 2,
//               decoration: const InputDecoration(hintText: "Lời nhắn nếu có")),

//           const SizedBox(height: 20),

//           ElevatedButton(
//             onPressed: selectedFrom != null &&
//                     selectedTo != null &&
//                     selectedDate != null &&
//                     serviceType != null
//                 ? _goToPayment
//                 : null,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               minimumSize: const Size(double.infinity, 50),
//             ),
//             child: const Text("Đặt ngay", style: TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//       bottomNavigationBar:
//           BottomNavBar(currentIndex: 1, username: widget.username),
//     );
//   }
// }
