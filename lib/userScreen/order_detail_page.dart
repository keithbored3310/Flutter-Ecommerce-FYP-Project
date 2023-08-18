import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:ecommerce/screens/sellers_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final String userOrderId;

  const OrderDetailsPage({
    required this.orderId,
    required this.userOrderId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('userOrders')
            .doc(userOrderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            var orderData = snapshot.data!.data() as Map<String, dynamic>;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(orderData['username']),
                  Text(orderData['phone']),
                  Text(orderData['address']),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderData['shopName'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SellerHomePage(
                                  sellerId: orderData['sellerId']),
                            ),
                          );
                        },
                        child: const Text('Go to Shop'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () async {
                      String productId = orderData['productId'];
                      DocumentSnapshot productSnapshot = await FirebaseFirestore
                          .instance
                          .collection('products')
                          .doc(productId)
                          .get();
                      if (productSnapshot.exists) {
                        var productData =
                            productSnapshot.data() as Map<String, dynamic>;
                        int maxQuantity = productData['quantity'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsUserScreen(
                              productData: productData,
                              maxQuantity: maxQuantity,
                              productId: productId,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Image.network(
                          orderData['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Name: ${orderData['productName']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Quantity: ${orderData['quantity']}'),
                            Text(
                              'Total Price: RM${orderData['itemTotalPrice'].toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (orderData['status'] == 3 || orderData['status'] == 4) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Tracking ID: ${orderData['trackingId']}'),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: orderData['trackingId']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Tracking ID copied to clipboard')),
                            );
                          },
                          child: const Text('Copy'),
                        ),
                      ],
                    ),
                    Text('Selected Courier: ${orderData['selectedCourier']}'),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Delivery Messages',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .collection('userOrders')
                        .doc(userOrderId)
                        .collection('deliveryMessage')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, deliveryMessageSnapshot) {
                      if (deliveryMessageSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (!deliveryMessageSnapshot.hasData ||
                          deliveryMessageSnapshot.data!.docs.isEmpty) {
                        return const Text('No delivery messages available.');
                      } else {
                        var deliveryMessages =
                            deliveryMessageSnapshot.data!.docs;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: deliveryMessages.map(
                            (messageDoc) {
                              var messageData =
                                  messageDoc.data() as Map<String, dynamic>;
                              var message = messageData['message'];
                              var timestamp = messageData['timestamp'].toDate();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$message',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Timestamp: ${timestamp.toString()}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Divider(),
                                ],
                              );
                            },
                          ).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
