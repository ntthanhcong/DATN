import 'package:booking_app/screens/user/select_seat_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BookingBusScreen extends StatefulWidget {
  final String username;
  const BookingBusScreen({super.key, required this.username});

  @override
  State<BookingBusScreen> createState() => _BookingBusScreenState();
}

class _BookingBusScreenState extends State<BookingBusScreen> {
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
        selectedDate = DateTime.now(); // reset ngày đi
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

  @override
  Widget build(BuildContext context) {
    final fromList = tripType == 'Chuyến đi' ? departures : arrivals;
    final toList = tripType == 'Chuyến đi' ? arrivals : departures;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đặt vé xe Út Ngân"),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔁 Chuyến đi / Chuyến về
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text("Chuyến đi"),
                          selected: tripType == 'Chuyến đi',
                          onSelected: (_) => _onTripTypeChanged('Chuyến đi'),
                          selectedColor: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text("Chuyến về"),
                          selected: tripType == 'Chuyến về',
                          onSelected: (_) => _onTripTypeChanged('Chuyến về'),
                          selectedColor: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 📍 Điểm đi - điểm đến + nút swap
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Tuyến đi",
                                  style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: fromLocation,
                                hint: const Text("Tuyến đi"),
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
                              const Text("Tuyến đến",
                                  style: TextStyle(color: Colors.grey)),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: toLocation,
                                hint: const Text("Tuyến đến"),
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

                    // 🗓️ Ngày đi
                    const Text("Ngày đi", style: TextStyle(color: Colors.grey)),
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

                    // 🔶 Nút tiếp theo
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (fromLocation != null && toLocation != null)
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SelectSeatScreen(
                                      from: fromLocation!,
                                      to: toLocation!,
                                      tripType: tripType,
                                      travelDate: selectedDate,
                                      username: widget.username,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
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
