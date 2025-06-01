import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:booking_app/widgets/admin_bottom_nav_bar.dart';
import '../../services/admin_service.dart'; // Ensure AdminService is properly implemented

class AdminManageConfigScreen extends StatefulWidget {
  const AdminManageConfigScreen({super.key});

  @override
  State<AdminManageConfigScreen> createState() =>
      _AdminManageConfigScreenState();
}

class _AdminManageConfigScreenState extends State<AdminManageConfigScreen> {
  final _service = AdminService();
  final _seatPriceController = TextEditingController();
  final _cargoPriceController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedType = 'departure'; // For managing locations
  String? _selectedCargoType; // To track the selected cargo type
  Map<String, dynamic>? _cargoTypes;

  @override
  void initState() {
    super.initState();
    _fetchCargoTypes();
  }

  // Fetch available cargo types from Firestore
  Future<void> _fetchCargoTypes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('cargo_types').get();

    setState(() {
      _cargoTypes = {for (var doc in snapshot.docs) doc.id: doc.data()};
    });
  }

  // Submit location information to Firestore
  void _submitNewLocation() {
    final name = _locationController.text.trim();
    if (name.isEmpty) return;

    final location = LocationModel(id: '', name: name, type: _selectedType);
    _service.addLocation(location);
    _locationController.clear();
  }

  // Update cargo price
  void _updateCargoPrice() async {
    if (_selectedCargoType != null && _cargoPriceController.text.isNotEmpty) {
      final newPrice = double.tryParse(_cargoPriceController.text.trim());
      if (newPrice != null) {
        await FirebaseFirestore.instance
            .collection('cargo_types')
            .doc(_selectedCargoType)
            .update({'price': newPrice});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã cập nhật giá gửi hàng')),
        );
      }
    }
  }

  Widget _buildSeatPriceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("💺 Cập nhật Giá vé chở người",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<double>(
              stream: _service.seatPriceStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final seatPrice = snapshot.data!;
                _seatPriceController.text = seatPrice.toStringAsFixed(0);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Giá hiện tại: ${seatPrice.toStringAsFixed(0)} VNĐ"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _seatPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Nhập giá mới cho vé chở người"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.check),
                          onPressed: () {
                            final newPrice = double.tryParse(
                                _seatPriceController.text.trim());
                            if (newPrice != null) {
                              _service.updateSeatPrice(newPrice);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('✅ Đã cập nhật giá vé')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build each section for updating prices
  Widget _buildPricingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("💵 Cập nhật Giá gửi hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Dropdown to select cargo type
            DropdownButton<String>(
              hint: const Text('Chọn loại hàng'),
              value: _selectedCargoType,
              onChanged: (newType) {
                setState(() {
                  _selectedCargoType = newType;
                  // Pre-fill the price when cargo type is selected
                  if (_selectedCargoType != null) {
                    _cargoPriceController.text =
                        _cargoTypes?[_selectedCargoType]?['price']
                                ?.toString() ??
                            '';
                  }
                });
              },
              items: _cargoTypes?.keys.map((key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(_cargoTypes![key]['name']),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // Price input field
            if (_selectedCargoType != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cargoPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Nhập giá mới cho gửi hàng (VNĐ)",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.check),
                    onPressed: _updateCargoPrice,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Location management section
  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📍 Quản lý địa điểm",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration:
                        const InputDecoration(labelText: "Nhập địa điểm mới"),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _selectedType,
                  items: const [
                    DropdownMenuItem(
                        value: 'departure', child: Text('Địa điểm 1')),
                    DropdownMenuItem(
                        value: 'arrival', child: Text('Địa điểm 2')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _submitNewLocation,
                  mini: true,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.check),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<LocationModel>>(
              stream: _service.locationsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final all = snapshot.data!;
                final locations1 =
                    all.where((e) => e.type == 'departure').toList();
                final locations2 =
                    all.where((e) => e.type == 'arrival').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🛫 Địa điểm 1",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...locations1
                        .map((loc) => _buildLocationTile(loc))
                        .toList(),
                    const SizedBox(height: 12),
                    const Text("🛬 Địa điểm 2",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    ...locations2
                        .map((loc) => _buildLocationTile(loc))
                        .toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editLocation(BuildContext context, LocationModel location) {
    final controller = TextEditingController(
        text: location.name); // Khởi tạo controller với tên địa điểm cũ

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Sửa địa điểm"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Tên địa điểm"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final updated = LocationModel(
                id: location.id,
                name: controller.text,
                type: location.type,
              );
              _service
                  .updateLocation(updated); // Cập nhật địa điểm trong Firestore
            },
            child: const Text("Lưu"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context), // Đóng dialog mà không lưu
            child: const Text("Huỷ"),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(LocationModel loc) {
    return ListTile(
      dense: true,
      title: Text(loc.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editLocation(context, loc),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _service.deleteLocation(loc.id),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _seatPriceController.dispose();
    _cargoPriceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cấu hình hệ thống"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSeatPriceSection(), // 👈 THÊM phần này trước
          const SizedBox(height: 20),
          _buildPricingSection(),
          const SizedBox(height: 20),
          _buildLocationSection(),
        ],
      ),
      bottomNavigationBar: const AdminBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}
