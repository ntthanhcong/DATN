import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_nav_bar.dart';

class HistoryScreen extends StatefulWidget {
  final String username;

  const HistoryScreen({super.key, required this.username});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _filterDate) {
      setState(() {
        _filterDate = picked;
      });
    }
  }

  void _clearDateFilter() {
    setState(() {
      _filterDate = null;
    });
  }

  Stream<QuerySnapshot> _filteredStream(String collection, bool isPassenger) {
    final baseQuery = FirebaseFirestore.instance
        .collection(collection)
        .where('username', isEqualTo: widget.username);

    if (_filterDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_filterDate!);
      return baseQuery
          .where('travelDate', isEqualTo: formattedDate)
          .snapshots();
    }

    return baseQuery.snapshots();
  }

  void _showDetailsDialog(BuildContext context, Map<String, dynamic> data) {
    final isCargo = data['serviceType'] == 'Gửi hàng';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isCargo ? "📦 Chi tiết đơn hàng" : "🎫 Chi tiết vé xe"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(" Họ tên: ${data['name'] ?? '---'}"),
              Text(" SĐT: ${data['phone'] ?? '---'}"),
              Text(" Mã ${isCargo ? 'đơn' : 'vé'}: ${data['id'] ?? '---'}"),
              Text("Tuyến: ${data['fromLocation']} → ${data['toLocation']}"),
              Text(
                  "Ngày: ${DateFormat('dd/MM/yyyy').format(data['travelDate'].toDate())}"),
              if (isCargo) ...[
                Text("Loại hàng: ${data['cargoType']}"),
                Text("Số lượng: ${data['quantity']} ${data['cargoUnit']}"),
                Text("Nơi lấy hàng: ${data['pickupAddress']}"),
                Text("Nơi giao hàng: ${data['dropoffAddress']}"),
              ] else ...[
                Text("Số ghế: ${data['selectedSeats']?.join(', ') ?? '---'}"),
                Text("Điểm đón: ${data['pickup']}"),
                Text("Điểm trả: ${data['dropoff']}"),
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

  Widget _buildList(String collection, bool isPassenger) {
    return StreamBuilder<QuerySnapshot>(
      stream: _filteredStream(collection, isPassenger),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Không có dữ liệu."));
        }

        final items = snapshot.data!.docs;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index].data() as Map<String, dynamic>;
            final Timestamp rawDate = data['travelDate'];
            final date = DateFormat('dd/MM/yyyy').format(rawDate.toDate());

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isPassenger
                              ? Icons.directions_bus
                              : Icons.local_shipping,
                          color: isPassenger ? Colors.blue : Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${data['id'] ?? '---'}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        TextButton(
                          onPressed: () => _showDetailsDialog(context, data),
                          child: const Text("Chi tiết"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(" Họ tên: ${data['name'] ?? '---'}"),
                    Text(" SĐT: ${data['phone'] ?? '---'}"),
                    Text(
                        "Tuyến: ${data['fromLocation']} → ${data['toLocation']}"),
                    Text("Ngày: $date"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Lịch sử đặt vé / giao hàng"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chở người'),
              Tab(text: 'Giao hàng'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _pickDate,
              tooltip: "Lọc theo ngày",
            ),
            if (_filterDate != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearDateFilter,
                tooltip: "Xóa lọc",
              ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildList('tickets', true),
            _buildList('cargo_orders', false),
          ],
        ),
        bottomNavigationBar:
            BottomNavBar(currentIndex: 1, username: widget.username),
      ),
    );
  }
}
