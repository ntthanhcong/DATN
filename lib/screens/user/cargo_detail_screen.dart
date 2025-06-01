import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'payment_for_cargo_screen.dart';

class CargoDetailScreen extends StatefulWidget {
  final String from;
  final String to;
  final String tripType;
  final DateTime travelDate;
  final String username;

  const CargoDetailScreen({
    super.key,
    required this.from,
    required this.to,
    required this.tripType,
    required this.travelDate,
    required this.username,
  });

  @override
  State<CargoDetailScreen> createState() => _CargoDetailScreenState();
}

class _CargoDetailScreenState extends State<CargoDetailScreen> {
  List<Map<String, dynamic>> cargoTypes = [];
  Map<String, dynamic>? selectedCargo;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController deliveryAddressController =
      TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCargoTypes();

    quantityController.addListener(() {
      setState(() {});
    });
  }

  Future<void> fetchCargoTypes() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('cargo_types').get();
    final types = snapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      cargoTypes = types;
      isLoading = false;
    });
  }

  int calculateTotal() {
    if (selectedCargo == null || quantityController.text.isEmpty) return 0;
    final price = selectedCargo!["price"] ?? 0;
    final quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    return price * quantity;
  }

  void goToPayment() {
    if (selectedCargo == null ||
        quantityController.text.isEmpty ||
        pickupAddressController.text.isEmpty ||
        deliveryAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng chọn loại hàng và điền đầy đủ thông tin!")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentForCargoScreen(
          username: widget.username,
          from: widget.from,
          to: widget.to,
          tripType: widget.tripType,
          travelDate: widget.travelDate,
          cargoType: selectedCargo!["name"],
          cargoUnit: selectedCargo!["unit"],
          cargoPricePerUnit: selectedCargo!["price"],
          quantity: int.tryParse(quantityController.text.trim()) ?? 0,
          pickupAddress: pickupAddressController.text.trim(),
          dropoffAddress: deliveryAddressController.text.trim(),
        ),
      ),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.from} → ${widget.to}',
                style: const TextStyle(fontSize: 18)),
            Text(formattedDate, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Loại hàng hóa:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...cargoTypes.map((type) => Card(
                  child: RadioListTile<Map<String, dynamic>>(
                    title: Text(
                        '${type["name"]} - ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(type["price"])} / ${type["unit"]}'),
                    value: type,
                    groupValue: selectedCargo,
                    onChanged: (val) => setState(() => selectedCargo = val),
                  ),
                )),
            const SizedBox(height: 16),
            _buildTextField(
                quantityController,
                selectedCargo != null
                    ? 'Số lượng (${selectedCargo!["unit"]})'
                    : 'Số lượng'),
            const SizedBox(height: 12),
            _buildTextField(
                pickupAddressController, 'Địa điểm lấy hàng cụ thể'),
            const SizedBox(height: 12),
            _buildTextField(
                deliveryAddressController, 'Địa điểm giao hàng cụ thể'),
            const SizedBox(height: 20),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.tripType, style: const TextStyle(fontSize: 14)),
                Text(
                  'Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(calculateTotal())}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: goToPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text("Tiếp tục", style: TextStyle(fontSize: 16)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
