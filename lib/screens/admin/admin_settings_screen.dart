// import 'package:flutter/material.dart';
// import '../services/admin_service.dart';

// class AdminSettingsScreen extends StatefulWidget {
//   const AdminSettingsScreen({Key? key}) : super(key: key);

//   @override
//   State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
// }

// class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
//   final _priceController = TextEditingController();
//   final _locNameController = TextEditingController();
//   String _locType = 'departure';

//   @override
//   void dispose() {
//     _priceController.dispose();
//     _locNameController.dispose();
//     super.dispose();
//   }

//   void _showAddLocationDialog() {
//     _locNameController.clear();
//     _locType = 'departure';
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Thêm địa điểm'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _locNameController,
//               decoration: const InputDecoration(labelText: 'Tên địa điểm'),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _locType,
//               items: const [
//                 DropdownMenuItem(value: 'departure', child: Text('Điểm đi')),
//                 DropdownMenuItem(value: 'arrival', child: Text('Điểm đến')),
//               ],
//               onChanged: (v) => setState(() => _locType = v!),
//               decoration: const InputDecoration(labelText: 'Loại'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Hủy')),
//           ElevatedButton(
//             onPressed: () {
//               final name = _locNameController.text.trim();
//               if (name.isNotEmpty) {
//                 AdminService().addLocation(
//                   LocationModel(id: '', name: name, type: _locType),
//                 );
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Lưu'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditLocationDialog(LocationModel loc) {
//     _locNameController.text = loc.name;
//     _locType = loc.type;
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Chỉnh sửa địa điểm'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: _locNameController,
//               decoration: const InputDecoration(labelText: 'Tên địa điểm'),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: _locType,
//               items: const [
//                 DropdownMenuItem(value: 'departure', child: Text('Điểm đi')),
//                 DropdownMenuItem(value: 'arrival', child: Text('Điểm đến')),
//               ],
//               onChanged: (v) => setState(() => _locType = v!),
//               decoration: const InputDecoration(labelText: 'Loại'),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Hủy')),
//           ElevatedButton(
//             onPressed: () {
//               final name = _locNameController.text.trim();
//               if (name.isNotEmpty) {
//                 final updated =
//                     LocationModel(id: loc.id, name: name, type: _locType);
//                 AdminService().updateLocation(updated);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text('Cập nhật'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Cài đặt hệ thống')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Giá vé (VNĐ)',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             StreamBuilder<double>(
//               stream: AdminService().seatPriceStream(),
//               builder: (context, snap) {
//                 if (!snap.hasData) return const CircularProgressIndicator();
//                 _priceController.text = snap.data!.toStringAsFixed(0);
//                 return Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _priceController,
//                         keyboardType: TextInputType.number,
//                         decoration:
//                             const InputDecoration(hintText: 'Nhập giá vé'),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         final val = double.tryParse(_priceController.text);
//                         if (val != null) AdminService().updateSeatPrice(val);
//                       },
//                       child: const Text('Cập nhật'),
//                     ),
//                   ],
//                 );
//               },
//             ),
//             const Divider(height: 32),
//             const Text('Danh sách địa điểm',
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//             Expanded(
//               child: StreamBuilder<List<LocationModel>>(
//                 stream: AdminService().locationsStream(),
//                 builder: (context, snap) {
//                   if (!snap.hasData)
//                     return const Center(child: CircularProgressIndicator());
//                   final list = snap.data!;
//                   return ListView.builder(
//                     itemCount: list.length,
//                     itemBuilder: (_, i) {
//                       final loc = list[i];
//                       return ListTile(
//                         title: Text(loc.name),
//                         subtitle: Text(
//                             loc.type == 'departure' ? 'Điểm đi' : 'Điểm đến'),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon: const Icon(Icons.edit),
//                               onPressed: () => _showEditLocationDialog(loc),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () =>
//                                   AdminService().deleteLocation(loc.id),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddLocationDialog,
//         child: const Icon(Icons.add),
//         tooltip: 'Thêm địa điểm',
//       ),
//     );
//   }
// }
