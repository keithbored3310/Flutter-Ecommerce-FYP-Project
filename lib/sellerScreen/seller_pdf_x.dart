// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ecommerce/sellerScreen/pdf_viewer.dart';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';

// class SellerPDFListScreen extends StatefulWidget {
//   final String sellerId;

//   SellerPDFListScreen({required this.sellerId});

//   @override
//   _SellerPDFListScreenState createState() => _SellerPDFListScreenState();
// }

// class _SellerPDFListScreenState extends State<SellerPDFListScreen> {
//   List<DocumentSnapshot> pdfList = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchSellerPDFs();
//   }

//   Future<void> fetchSellerPDFs() async {
//     try {
//       final pdfCollection = FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(widget.sellerId)
//           .collection('pdfs');

//       final pdfQuery = await pdfCollection.get();

//       setState(() {
//         pdfList = pdfQuery.docs;
//       });
//     } catch (error) {
//       print('Error fetching seller PDFs: $error');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Seller PDFs'),
//       ),
//       body: ListView.builder(
//         itemCount: pdfList.length,
//         itemBuilder: (context, index) {
//           final pdfData = pdfList[index].data() as Map<String, dynamic>;
//           final pdfUrl = pdfData['pdfUrl'];
//           final pdfName = pdfData['pdfName'];

//           return ListTile(
//             title: Text(pdfName),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PDFViewerScreen(pdfUrl: pdfUrl),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
