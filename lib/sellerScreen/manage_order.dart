import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widget/courier_drop_down.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ManageOrderPage extends StatefulWidget {
  final String sellerId;

  const ManageOrderPage({required this.sellerId});

  @override
  State<ManageOrderPage> createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  String? _selectedCourier;

  void updateSelectedCourier(String? courier) {
    setState(() {
      _selectedCourier = courier;
    });
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
        // ... other fields to update
      });
    } catch (error) {
      print('Error updating status: $error');
      // Handle error
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders for Seller'),
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

            return ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: userOrders.map(
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
