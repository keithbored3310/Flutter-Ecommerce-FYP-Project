import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widget/courier_drop_down.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ManageOrderPage extends StatefulWidget {
  final String sellerId;

  const ManageOrderPage({super.key, required this.sellerId});

  @override
  State<ManageOrderPage> createState() {
    return _ManageOrderPageState();
  }
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  String? _selectedCourier; // Add this line to your _ManageOrderPageState

  void updateSelectedCourier(String? courier) {
    setState(() {
      _selectedCourier = courier;
    });
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getUserOrders() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userOrdersSnapshot =
          await FirebaseFirestore.instance
              .collectionGroup('userOrders')
              .where('sellerId', isEqualTo: widget.sellerId)
              .where('status', whereIn: [2, 3, 4]).get();
      return userOrdersSnapshot;
    } catch (error) {
      print('Error fetching user orders: $error');
      throw error;
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
        return 'Unknown'; // Handle other status values if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders for Seller'),
      ),
      body: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: _getUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.size == 0) {
            return Text('No data available');
          } else {
            final userOrders = snapshot.data!.docs;

            return ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: userOrders.map(
                  (userOrder) {
                    final userOrderData = userOrder.data();
                    final userOrderId = userOrderData['userOrderId'];
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
                            icon: Icon(Icons.local_shipping),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Select Courier'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CourierDropdown(
                                          selectedCourier: _selectedCourier,
                                          onCourierChanged:
                                              updateSelectedCourier,
                                        ),
                                        SizedBox(height: 20),
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
                                                final orderId =
                                                    userOrderData['orderId'];
                                                final DateTime now =
                                                    DateTime.now();

                                                final newStatus =
                                                    3; // Status to update

                                                try {
                                                  // Update the status in Firestore
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('orders')
                                                      .doc(orderId)
                                                      .collection('userOrders')
                                                      .doc(userOrderIdToUpdate)
                                                      .update({
                                                    'status': newStatus,
                                                    'trackingId': newTrackingId,
                                                    'selectedCourier':
                                                        _selectedCourier,
                                                  });

                                                  // Add a new document to the deliveryMessage subcollection
                                                  await FirebaseFirestore
                                                      .instance
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

                                                  // Show a snackbar and pop the dialog
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Item is shipped.'),
                                                    ),
                                                  );
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                } catch (error) {
                                                  print(
                                                      'Error updating status: $error');
                                                  // Handle error
                                                }
                                              },
                                              child: Text('Ship'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(
                                                    context); // Close the dialog
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
                        : IconButton(
                            icon: Icon(Icons.local_shipping),
                            onPressed:
                                null, // Set onPressed to null when status is not 2
                            color: Colors.grey, // Change the color of the icon
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
