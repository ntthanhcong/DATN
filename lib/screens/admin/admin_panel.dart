// // lib/screens/admin_panel.dart
// import 'package:flutter/material.dart';
// import '../services/admin_service.dart';
// import '../services/admin_service.dart' show LocationModel;

// class AdminPanel extends StatefulWidget {
//   const AdminPanel({Key? key}) : super(key: key);

//   @override
//   State<AdminPanel> createState() => _AdminPanelState();
// }

// class _AdminPanelState extends State<AdminPanel> {
//   final _admin = AdminService();
//   final _priceController = TextEditingController();

//   @override
//   void dispose() {
//     _priceController.dispose();
//     super.dispose();
//   }

//   Widget _buildPricingSection() {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("🔖 Giá vé (VNĐ)",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             StreamBuilder<double>(
//               stream: _admin.seatPriceStream(),
//               builder: (ctx, snap) {
//                 if (!snap.hasData)
//                   return const Center(child: CircularProgressIndicator());
//                 _priceController.text = snap.data!.toStringAsFixed(0);
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _priceController,
//                         keyboardType: TextInputType.number,
//                         decoration: const InputDecoration(labelText: "Giá vé"),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         final newPrice = double.tryParse(_priceController.text);
//                         if (newPrice != null) {
//                           _admin.updateSeatPrice(newPrice);
//                           ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text("Cập nhật giá vé thành công")));
//                         }
//                       },
//                       child: const Text("Lưu"),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationsSection() {
//     return Card(
//       margin: const EdgeInsets.all(8),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("📍 Quản lý Địa điểm",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             ElevatedButton.icon(
//               onPressed: () => _showLocationDialog(),
//               icon: const Icon(Icons.add),
//               label: const Text("Thêm Địa điểm"),
//             ),
//             const SizedBox(height: 8),
//             StreamBuilder<List<LocationModel>>(
//               stream: _admin.locationsStream(),
//               builder: (ctx, snap) {
//                 if (!snap.hasData)
//                   return const Center(child: CircularProgressIndicator());
//                 final list = snap.data!;
//                 if (list.isEmpty) return const Text("Chưa có địa điểm nào.");
//                 return ListView.separated(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: list.length,
//                   separatorBuilder: (_, __) => const Divider(),
//                   itemBuilder: (ctx, i) {
//                     final loc = list[i];
//                     return ListTile(
//                       title: Text(loc.name),
//                       subtitle: Text(
//                           loc.type == 'departure' ? 'Điểm đi' : 'Điểm đến'),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: const Icon(Icons.edit),
//                             onPressed: () => _showLocationDialog(loc: loc),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _admin.deleteLocation(loc.id),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showLocationDialog({LocationModel? loc}) {
//     final nameCtrl = TextEditingController(text: loc?.name);
//     var type = loc?.type ?? 'departure';

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(loc == null ? "Thêm địa điểm" : "Sửa địa điểm"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//                 controller: nameCtrl,
//                 decoration: const InputDecoration(labelText: "Tên địa điểm")),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: type,
//               items: const [
//                 DropdownMenuItem(value: 'departure', child: Text('Điểm đi')),
//                 DropdownMenuItem(value: 'arrival', child: Text('Điểm đến')),
//               ],
//               onChanged: (v) => type = v!,
//               decoration: const InputDecoration(labelText: "Loại"),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Hủy")),
//           ElevatedButton(
//             onPressed: () {
//               final model = LocationModel(
//                   id: loc?.id ?? '', name: nameCtrl.text, type: type);
//               if (loc == null) {
//                 _admin.addLocation(model);
//               } else {
//                 _admin.updateLocation(model);
//               }
//               Navigator.pop(context);
//             },
//             child: const Text("Lưu"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("🚀 Bảng Admin")),
//       body: ListView(
//         children: [
//           _buildPricingSection(),
//           _buildLocationsSection(),
//         ],
//       ),
//     );
//   }
// }
