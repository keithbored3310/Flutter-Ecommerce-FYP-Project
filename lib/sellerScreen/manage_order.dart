import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widget/courier_drop_down.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart'; // Add this import
// import 'package:flutter/services.dart'; // Add this import for permission handling
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class ManageOrderPage extends StatefulWidget {
  final String sellerId;

  const ManageOrderPage({super.key, required this.sellerId});

  @override
  State<ManageOrderPage> createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  String? _selectedCourier;
  int? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  void updateSelectedCourier(String? courier) {
    setState(() {
      _selectedCourier = courier;
    });
  }

  Future<Map<String, dynamic>> fetchSellerData(String sellerId) async {
    try {
      final sellerDoc = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerId)
          .get();

      if (sellerDoc.exists) {
        final sellerData = sellerDoc.data() as Map<String, dynamic>;
        final shopName = sellerData['shopName'];
        final pickupAddress = sellerData['pickupAddress'];

        return {
          'shopName': shopName,
          'pickupAddress': pickupAddress,
        };
      }
    } catch (error) {
      // print('Error fetching seller data: $error');
    }

    return {};
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _userOrdersStream() {
    return FirebaseFirestore.instance
        .collectionGroup('userOrders')
        .where('sellerId', isEqualTo: widget.sellerId)
        .where('status', whereIn: [2, 3, 4]).snapshots();
  }

  void _updateOrderStatus(
    String orderId,
    String userOrderId,
    int newStatus,
    String newTrackingId,
    String selectedCourier,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('userOrders')
          .doc(userOrderId)
          .update({
        'status': newStatus,
        'trackingId': newTrackingId,
        'selectedCourier': selectedCourier,
      });
    } catch (error) {
      // print('Error updating status: $error');
    }
  }

  String generateTrackingId() {
    Random random = Random();
    String trackingId = '';
    for (int i = 0; i < 16; i++) {
      trackingId += random.nextInt(10).toString();
    }
    return trackingId;
  }

  String getStatusText(int status) {
    switch (status) {
      case 2:
        return 'To Ship';
      case 3:
        return 'To Receive';
      case 4:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  Future<void> requestStoragePermission() async {
    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
    } else {}
  }

  Future<void> generateAndSavePDF(
    String username,
    String phone,
    String address,
    String userOrderId,
    String timestamp,
    String? selectedCourier,
    String sellerId,
  ) async {
    await requestStoragePermission();

    // final appDocDir = await getExternalStorageDirectory();
    final path = (await getExternalStorageDirectory())?.path ?? '';

    // Fetch seller data
    final sellerData = await fetchSellerData(sellerId);
    final shopName = sellerData['shopName'] ?? '';
    final pickupAddress = sellerData['pickupAddress'] ?? '';

    // Create a PDF document
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Order Details
              pw.Text('Order Details',
                  style: pw.TextStyle(
                      font: pw.Font.helveticaBold(), fontSize: 20)),
              pw.Divider(thickness: 2, height: 20),
              pw.Text('User Order ID: $userOrderId'),
              pw.Text('Timestamp: $timestamp'),
              pw.Text('Selected Courier: $selectedCourier'),
              pw.Divider(thickness: 2, height: 20),

              // Seller Details
              pw.Text('Seller Details',
                  style: pw.TextStyle(
                      font: pw.Font.helveticaBold(), fontSize: 20)),
              pw.Divider(thickness: 2, height: 20),
              pw.Text('Seller ID: $sellerId'),
              pw.Text('Shop Name: $shopName'),
              pw.Text('Pickup Address: $pickupAddress'),
              pw.Divider(thickness: 2, height: 20),

              // Receiver Details
              pw.Text('Receiver Details',
                  style: pw.TextStyle(
                      font: pw.Font.helveticaBold(), fontSize: 20)),
              pw.Divider(thickness: 2, height: 20),
              pw.Text('Username: $username'),
              pw.Text('Phone: $phone'),
              pw.Text('Address: $address'),
            ],
          );
        },
      ),
    );

    // Serialize the PDF as bytes
    final pdfBytes = await pdf.save();

    // Generate a unique PDF ID (you can use a package like 'uuid' for this)
    // final pdfId = 'pdf_${Uuid().v4()}';

    // Set the PDF name to include the timestamp
    final pdfName = '$username-$timestamp.pdf';
    final fileName = '$pdfName';
    // Save the PDF to external storage
    final file = File('$path/$fileName');
    await file.writeAsBytes(pdfBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF saved to external storage: ${file.path}'),
      ),
    );
    // Print the path where the PDF is saved
    // print('PDF saved to external storage: ${file.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders for Seller'),
        actions: [
          DropdownButton<int>(
            value: _selectedStatusFilter,
            onChanged: (value) {
              setState(() {
                _selectedStatusFilter = value;
              });
            },
            items: const [
              DropdownMenuItem<int>(
                value: null,
                child: Text('All'),
              ),
              DropdownMenuItem<int>(
                value: 2,
                child: Text('To Ship'),
              ),
              DropdownMenuItem<int>(
                value: 3,
                child: Text('To Receive'),
              ),
              DropdownMenuItem<int>(
                value: 4,
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _userOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.size == 0) {
            return const Center(
              child: Text('No data available', style: TextStyle(fontSize: 20)),
            );
          } else {
            final userOrders = snapshot.data!.docs;

            final filteredUserOrders = _selectedStatusFilter == null
                ? userOrders
                : userOrders
                    .where((userOrder) =>
                        userOrder.data()['status'] == _selectedStatusFilter)
                    .toList();

            return ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: filteredUserOrders.map(
                  (userOrder) {
                    final userOrderData = userOrder.data();
                    final userOrderId = userOrderData['userOrderId'];
                    final orderId = userOrderData['orderId'];
                    final imageUrl = userOrderData['imageUrl'];
                    final username = userOrderData['username'];
                    final phone = userOrderData['phone'];
                    final address = userOrderData['address'];
                    final timestamp = userOrderData['timestamp'].toDate();
                    final productName = userOrderData['productName'];
                    final quantity = userOrderData['quantity'];
                    final itemTotalPrice = userOrderData['itemTotalPrice'];
                    final status = userOrderData['status'];
                    final timestampString = timestamp.toString();

                    final statusColumn = status == 2
                        ? IconButton(
                            icon: const Icon(Icons.local_shipping),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Select Courier'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CourierDropdown(
                                          selectedCourier: _selectedCourier,
                                          onCourierChanged:
                                              updateSelectedCourier,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                await generateAndSavePDF(
                                                  username,
                                                  phone,
                                                  address,
                                                  userOrderId,
                                                  timestampString,
                                                  _selectedCourier,
                                                  widget.sellerId,
                                                );
                                              },
                                              child: const Text('Generate PDF'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                String newTrackingId =
                                                    generateTrackingId();
                                                final userOrderIdToUpdate =
                                                    userOrderData[
                                                        'userOrderId'];
                                                final DateTime now =
                                                    DateTime.now();

                                                const newStatus = 3;

                                                // Update status in Firestore
                                                _updateOrderStatus(
                                                  orderId,
                                                  userOrderIdToUpdate,
                                                  newStatus,
                                                  newTrackingId,
                                                  _selectedCourier ?? '',
                                                );

                                                // Add delivery message
                                                await FirebaseFirestore.instance
                                                    .collection('orders')
                                                    .doc(orderId)
                                                    .collection('userOrders')
                                                    .doc(userOrderIdToUpdate)
                                                    .collection(
                                                        'deliveryMessage')
                                                    .add({
                                                  'message':
                                                      'Seller is shipped out the parcel',
                                                  'timestamp': now,
                                                });

                                                // Show snackbar and pop dialog
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Item is shipped.'),
                                                  ),
                                                );
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Ship'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('Cancel'),
                                              style: ElevatedButton.styleFrom(
                                                primary: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : const IconButton(
                            icon: Icon(Icons.local_shipping),
                            onPressed: null,
                            color: Colors.grey,
                          );

                    return ListTile(
                      leading: Image.network(imageUrl),
                      title: Text('Username: $username'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Phone: $phone'),
                          Text('Address: $address'),
                          Text('User Order ID: $userOrderId'),
                          Text('Date: ${timestamp.toString().split(' ')[0]}'),
                          Text('Product: $productName'),
                          Text('Quantity: $quantity'),
                          Text('Total Price: $itemTotalPrice'),
                          Text('Status: ${getStatusText(status)}'),
                        ],
                      ),
                      trailing: statusColumn,
                    );
                  },
                ),
              ).toList(),
            );
          }
        },
      ),
    );
  }
}
