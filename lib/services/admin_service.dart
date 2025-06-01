import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final _db = FirebaseFirestore.instance;

  /// 🔹 Stream giá vé chở người
  Stream<double> seatPriceStream() {
    return _db
        .collection('settings')
        .doc('pricing')
        .snapshots()
        .map((snap) => (snap.data()?['seatPrice'] as num).toDouble());
  }

  /// 🔹 Stream giá gửi hàng
  Stream<double> cargoPriceStream() {
    return _db
        .collection('settings')
        .doc('pricing')
        .snapshots()
        .map((snap) => (snap.data()?['cargoPrice'] as num).toDouble());
  }

  /// 🔹 Cập nhật giá vé chở người
  Future<void> updateSeatPrice(double newPrice) {
    return _db.collection('settings').doc('pricing').update({
      'seatPrice': newPrice,
    });
  }

  /// 🔹 Cập nhật giá gửi hàng
  Future<void> updateCargoPrice(double newPrice) {
    return _db.collection('settings').doc('pricing').update({
      'cargoPrice': newPrice,
    });
  }

  /// 🔹 Stream danh sách địa điểm
  Stream<List<LocationModel>> locationsStream() {
    return _db
        .collection('locations')
        .snapshots()
        .map((snap) => snap.docs.map((d) => LocationModel.fromDoc(d)).toList());
  }

  Future<void> addLocation(LocationModel loc) {
    return _db.collection('locations').add(loc.toMap());
  }

  Future<void> updateLocation(LocationModel loc) {
    return _db.collection('locations').doc(loc.id).update(loc.toMap());
  }

  Future<void> deleteLocation(String id) {
    return _db.collection('locations').doc(id).delete();
  }

  /// ✅ Tổng số người dùng (dành cho AdminOverview)
  Stream<int> totalUserCount() {
    return _db.collection('users').snapshots().map((snap) => snap.docs.length);
  }

  /// ✅ Tổng số chuyến đi theo ngày (yyyy-MM-dd)
  Stream<int> tripsCountByDate(String date) {
    return _db
        .collection('trips')
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}

/// 🔸 Mô hình địa điểm
class LocationModel {
  final String id;
  final String name;
  final String type; // 'departure' or 'arrival'

  LocationModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory LocationModel.fromDoc(DocumentSnapshot d) {
    final data = d.data() as Map<String, dynamic>;
    return LocationModel(
      id: d.id,
      name: data['name'],
      type: data['type'],
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
      };
}
