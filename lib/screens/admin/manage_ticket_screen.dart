import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageTicketScreen extends StatefulWidget {
  const ManageTicketScreen({super.key});

  @override
  State<ManageTicketScreen> createState() => _ManageTicketScreenState();
}

class _ManageTicketScreenState extends State<ManageTicketScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final isCargo = data['serviceType'] == 'Gửi hàng';
    final travelDate = data['travelDate'];
    final formattedDate = travelDate is Timestamp
        ? DateFormat('dd/MM/yyyy').format(travelDate.toDate())
        : travelDate.toString(); // fallback nếu bị sai định dạng

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCargo ? "📦 Chi tiết đơn hàng" : "🎫 Chi tiết vé xe"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" Tên người dùng: ${data['username']}"),
              Text(" Mã vé: ${data['id'] ?? '---'}"),
              Text("Tuyến: ${data['fromLocation']} → ${data['toLocation']}"),
              Text("Ngày: $formattedDate"),
              if (isCargo) ...[
                Text("Loại hàng: ${data['cargoType']}"),
                Text("Số lượng: ${data['quantity']} ${data['cargoUnit']}"),
                Text("Nơi lấy hàng: ${data['pickupAddress']}"),
                Text("Nơi giao hàng: ${data['dropoffAddress']}"),
              ] else ...[
                Text("Số ghế: ${data['selectedSeats']?.join(', ') ?? '---'}"),
                Text(
                    "Điểm đón: ${data['pickup'] ?? data['fromAddress'] ?? ''}"),
                Text("Điểm trả: ${data['dropoff'] ?? data['toAddress'] ?? ''}"),
              ],
              const SizedBox(height: 8),
              Text(
                  "💰 Tổng tiền: ${data['totalPrice']?.toStringAsFixed(0) ?? '0'}đ"),
              Text(
                  "⏱️ Ngày tạo: ${data['createdAt']?.toDate().toString().substring(0, 19) ?? '---'}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final end = start.add(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý vé xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Chọn ngày',
            onPressed: _pickDate,
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Ngày được chọn: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('tickets')
                  .where('travelDate',
                      isGreaterThanOrEqualTo: Timestamp.fromDate(start))
                  .where('travelDate', isLessThan: Timestamp.fromDate(end))
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = snapshot.data!.docs;

                if (tickets.isEmpty) {
                  return const Center(
                      child: Text("Không có vé trong ngày này."));
                }

                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: GestureDetector(
                          onTap: () {
                            _showDetailsDialog(
                                context, ticket.data() as Map<String, dynamic>);
                          },
                          child: Text(
                            ticket['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        subtitle:
                            Text('Ghế đã chọn: ${ticket['selectedSeats']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(context, ticket.id,
                                    ticket.data() as Map<String, dynamic>);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Xác nhận xóa'),
                                    content: const Text(
                                        'Bạn có chắc muốn xóa vé này không?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Hủy'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(
                                              context); // đóng hộp thoại xác nhận
                                          await deleteTicket(ticket.id);
                                        },
                                        child: const Text('Xóa',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Hộp thoại chỉnh sửa thông tin vé
  void _showEditDialog(
      BuildContext context, String ticketId, Map<String, dynamic> ticketData) {
    final TextEditingController usernameController =
        TextEditingController(text: ticketData['name']);
    final TextEditingController notePhoneController =
        TextEditingController(text: ticketData['phone']);
    final TextEditingController travelDateController = TextEditingController(
        text: (ticketData['travelDate'] as Timestamp)
            .toDate()
            .toString()
            .split(' ')[0]);
    final TextEditingController fromAddressController =
        TextEditingController(text: ticketData['pickup']);
    final TextEditingController toAddressController =
        TextEditingController(text: ticketData['dropoff']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chỉnh sửa vé xe'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Tên hành khách'),
                ),
                TextField(
                  controller: notePhoneController,
                  decoration: InputDecoration(labelText: 'Số điện thoại'),
                ),
                TextField(
                  controller: fromAddressController,
                  decoration: InputDecoration(labelText: 'Địa chỉ điểm đón'),
                ),
                TextField(
                  controller: toAddressController,
                  decoration: InputDecoration(labelText: 'Địa chỉ điểm đến'),
                ), // Ghi chú
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Map<String, dynamic> updatedData = {
                  'name': usernameController.text,
                  'pickup': fromAddressController.text,
                  'dropoff': toAddressController.text,
                  'phone': notePhoneController.text,
                };

                await updateTicket(ticketId, updatedData);
                Navigator.of(context).pop(); // đóng hộp thoại

                // 🟢 Hiển thị SnackBar thông báo thành công
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Cập nhật vé thành công'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Cập nhật vé xe vào Firestore
  Future<void> updateTicket(
      String ticketId, Map<String, dynamic> updatedData) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update(updatedData);
    } catch (e) {
      print('Lỗi cập nhật vé xe: $e');
    }
  }

  // Xóa vé xe
  Future<void> deleteTicket(String ticketId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .delete();
    } catch (e) {
      print('Lỗi xóa vé xe: $e');
    }
  }
}
