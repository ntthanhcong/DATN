// import 'dart:io';
// import 'dart:typed_data';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import '../models/booking_info.dart';
// import 'package:flutter/services.dart' show rootBundle;

// Future<Uint8List> generateBookingPdf(
//     BookingInfo booking, int totalPrice) async {
//   final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
//   final ttf = pw.Font.ttf(fontData);

//   final pdf = pw.Document();

//   pdf.addPage(
//     pw.Page(
//       build: (context) => pw.Padding(
//         padding: const pw.EdgeInsets.all(20),
//         child: pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.start,
//           children: [
//             pw.Text("VÉ XE ĐIỆN TỬ",
//                 style: pw.TextStyle(
//                     font: ttf, fontSize: 24, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 10),
//             pw.Text("Người đặt: ${booking.username}",
//                 style: pw.TextStyle(font: ttf)),
//             pw.Text("Loại dịch vụ: ${booking.serviceType}",
//                 style: pw.TextStyle(font: ttf)),
//             pw.Text("Điểm đi: ${booking.fromLocation} (${booking.fromAddress})",
//                 style: pw.TextStyle(font: ttf)),
//             pw.Text("Điểm đến: ${booking.toLocation} (${booking.toAddress})",
//                 style: pw.TextStyle(font: ttf)),
//             pw.Text("Ngày đi: ${booking.travelDate}",
//                 style: pw.TextStyle(font: ttf)),
//             if (booking.serviceType == "Chở người")
//               pw.Text("Ghế: ${booking.selectedSeats.join(', ')}",
//                   style: pw.TextStyle(font: ttf)),
//             if (booking.serviceType == "Gửi hàng")
//               pw.Text(
//                   "Hàng hóa: ${booking.cargoType} - ${booking.cargoWeight}kg",
//                   style: pw.TextStyle(font: ttf)),
//             pw.SizedBox(height: 12),
//             pw.Text("Tổng tiền: ${totalPrice.toString()} VND",
//                 style: pw.TextStyle(font: ttf, fontSize: 18)),
//             pw.SizedBox(height: 20),
//             pw.Text("Cảm ơn quý khách đã sử dụng dịch vụ!",
//                 style: pw.TextStyle(font: ttf)),
//           ],
//         ),
//       ),
//     ),
//   );

//   return pdf.save();
// }
