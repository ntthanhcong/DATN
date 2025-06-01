import 'package:booking_app/screens/user/cargo_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SendCargoScreen extends StatefulWidget {
  final String username;
  const SendCargoScreen({super.key, required this.username});

  @override
  State<SendCargoScreen> createState() => _SendCargoScreenState();
}

class _SendCargoScreenState extends State<SendCargoScreen> {
  String tripType = 'Chuyến đi';
  String? fromLocation;
  String? toLocation;
  DateTime selectedDate = DateTime.now();

  List<String> departures = [];
  List<String> arrivals = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locations').get();

    final List<String> dep = [];
    final List<String> arr = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['type'] == 'departure') dep.add(data['name']);
      if (data['type'] == 'arrival') arr.add(data['name']);
    }

    setState(() {
      departures = dep;
      arrivals = arr;
      isLoading = false;
    });
  }

  void _onTripTypeChanged(String type) {
    if (tripType != type) {
      final oldFrom = fromLocation;
      final oldTo = toLocation;

      setState(() {
        tripType = type;
        fromLocation = oldTo;
        toLocation = oldFrom;
        selectedDate = DateTime.now();
      });
    }
  }

  void _swapLocations() {
    setState(() {
      final temp = fromLocation;
      fromLocation = toLocation;
      toLocation = temp;
    });
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String getFormattedDate(DateTime date) => DateFormat('dd/MM').format(date);

  String getWeekday(DateTime date) => DateFormat.EEEE('vi_VN').format(date);

  void _goToCargoDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CargoDetailScreen(
          username: widget.username,
          from: fromLocation!,
          to: toLocation!,
          tripType: tripType,
          travelDate: selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fromList = tripType == 'Chuyến đi' ? departures : arrivals;
    final toList = tripType == 'Chuyến đi' ? arrivals : departures;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gửi hàng Út Ngân"),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("Chuyến đi"),
                          selected: tripType == 'Chuyến đi',
                          onSelected: (_) => _onTripTypeChanged('Chuyến đi'),
                          selectedColor: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text("Chuyến về"),
                          selected: tripType == 'Chuyến về',
                          onSelected: (_) => _onTripTypeChanged('Chuyến về'),
                          selectedColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Điểm gửi",
                                  style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: fromLocation,
                                hint: const Text("Điểm gửi"),
                                items: fromList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => fromLocation = val),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _swapLocations,
                          icon: const Icon(Icons.swap_horiz),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Điểm nhận",
                                  style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: toLocation,
                                hint: const Text("Điểm nhận"),
                                items: toList
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                                onChanged: (val) =>
                                    setState(() => toLocation = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("Ngày gửi",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              getFormattedDate(selectedDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              getWeekday(selectedDate),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (fromLocation != null && toLocation != null)
                            ? _goToCargoDetail
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text("Tiếp theo",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
