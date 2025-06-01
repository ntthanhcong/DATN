import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _generateTicketId(String orderId) {
    final prefix = 'NXUNCN';
    final shortOrderId = orderId
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .substring(0, 8)
        .toUpperCase();
    return '$prefix-$shortOrderId';
  }

  Future<void> savePassengerTicket({
    required String username,
    required String fullName,
    required String phone,
    required String email,
    required String from,
    required String to,
    required DateTime travelDate,
    required List<String> seats,
    required String pickup,
    required String dropoff,
    required String orderId,
    required int totalAmount,
    required String tripType,
  }) async {
    final ticketId = _generateTicketId(orderId);

    await _db.collection('tickets').add({
      "id": ticketId,
      "username": username,
      "name": fullName,
      "phone": phone,
      "email": email,
      "fromLocation": from,
      "toLocation": to,
      "selectedSeats": seats,
      "pickup": pickup,
      "dropoff": dropoff,
      "travelDate": travelDate,
      "totalPrice": totalAmount,
      "paymentMethod": "MoMo",
      "serviceType": "Chở người",
      "createdAt": Timestamp.now(),
      "orderId": orderId,
      "tripType": tripType,
    });
  }
}
