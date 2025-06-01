import 'package:cloud_firestore/cloud_firestore.dart';

class TicketInfo {
  final String id;
  final String username;
  final String name;
  final String bookingDate;
  final String fromLocation;
  final String fromAddress;
  final String toLocation;
  final String toAddress;
  final List<String> selectedSeats;
  final String paymentMethod;
  final double totalPrice;
  final String serviceType;
  final String? receiverPhone;
  final Timestamp createdAt;

  TicketInfo({
    required this.id,
    required this.username,
    required this.name,
    required this.bookingDate,
    required this.fromLocation,
    required this.fromAddress,
    required this.toLocation,
    required this.toAddress,
    required this.selectedSeats,
    required this.paymentMethod,
    required this.totalPrice,
    required this.serviceType,
    this.receiverPhone,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'name': name,
        'bookingDate': bookingDate,
        'fromLocation': fromLocation,
        'fromAddress': fromAddress,
        'toLocation': toLocation,
        'toAddress': toAddress,
        'selectedSeats': selectedSeats,
        'paymentMethod': paymentMethod,
        'totalPrice': totalPrice,
        'serviceType': serviceType,
        'receiverPhone': receiverPhone,
        'createdAt': createdAt,
      };

  factory TicketInfo.fromJson(Map<String, dynamic> json) => TicketInfo(
        id: json['id'],
        username: json['username'],
        name: json['name'],
        bookingDate: json['bookingDate'],
        fromLocation: json['fromLocation'],
        fromAddress: json['fromAddress'],
        toLocation: json['toLocation'],
        toAddress: json['toAddress'],
        selectedSeats: List<String>.from(json['selectedSeats']),
        paymentMethod: json['paymentMethod'],
        totalPrice: (json['totalPrice'] as num).toDouble(),
        serviceType: json['serviceType'],
        receiverPhone: json['receiverPhone'],
        createdAt: json['createdAt'],
      );
}
