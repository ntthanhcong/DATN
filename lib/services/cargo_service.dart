import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class CargoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _generateCargoId(String orderId) {
    final prefix = 'NXUNGH';
    final shortOrderId = orderId
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .substring(0, 8)
        .toUpperCase();
    return '$prefix-$shortOrderId';
  }

  Future<void> saveCargoOrder({
    required String username,
    required String fullName,
    required String phone,
    required String email,
    required String from,
    required String to,
    required DateTime travelDate,
    required String cargoType,
    required String cargoUnit,
    required int quantity,
    required int pricePerUnit,
    required String pickupAddress,
    required String dropoffAddress,
    required String orderId,
    required String tripType,
  }) async {
    final total = quantity * pricePerUnit;
    final cargoId = _generateCargoId(orderId);

    await _db.collection('cargo_orders').add({
      "id": cargoId,
      "username": username,
      "name": fullName,
      "phone": phone,
      "email": email,
      "fromLocation": from,
      "toLocation": to,
      "pickupAddress": pickupAddress,
      "dropoffAddress": dropoffAddress,
      "cargoType": cargoType,
      "cargoUnit": cargoUnit,
      "quantity": quantity,
      "unitPrice": pricePerUnit,
      "totalPrice": total,
      "travelDate": travelDate,
      "paymentMethod": "MoMo",
      "serviceType": "Gửi hàng",
      "createdAt": Timestamp.now(),
      "orderId": orderId,
      "tripType": tripType,
    });
  }
}
