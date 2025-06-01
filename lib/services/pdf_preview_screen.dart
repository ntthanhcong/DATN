// import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
// import 'dart:typed_data';

// class PdfPreviewScreen extends StatelessWidget {
//   final Future<Uint8List> pdfData;
//   final String fileName;

//   const PdfPreviewScreen({
//     super.key,
//     required this.pdfData,
//     required this.fileName,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Xem hóa đơn: $fileName")),
//       body: PdfPreview(
//         build: (format) => pdfData,
//         canChangePageFormat: false,
//         canChangeOrientation: false,
//         allowSharing: true,
//         allowPrinting: true,
//         pdfFileName: fileName,
//       ),
//     );
//   }
// }
