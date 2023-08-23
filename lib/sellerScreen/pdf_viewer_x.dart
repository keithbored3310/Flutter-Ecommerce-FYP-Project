// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

// class PDFViewerScreen extends StatefulWidget {
//   final String pdfUrl;

//   PDFViewerScreen({required this.pdfUrl});

//   @override
//   _PDFViewerScreenState createState() => _PDFViewerScreenState();
// }

// class _PDFViewerScreenState extends State<PDFViewerScreen> {
//   PDFDocument? document;

//   void initialisePdf() async {
//     document = await PDFDocument.fromURL(widget.pdfUrl);
//     setState(() {});
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     initialisePdf();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Viewer'),
//       ),
//       body: document != null
//           ? PDFViewer(document: document!)
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }
