import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/userScreen/order_detail_page.dart';

class UserActivityScreen extends StatefulWidget {
  final String userUid;

  const UserActivityScreen({
    required this.userUid,
    super.key,
  });

  @override
  State<UserActivityScreen> createState() => _UserActivityScreenState();
}

class _UserActivityScreenState extends State<UserActivityScreen> {
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      fetchUserOrders() async {
    final userOrdersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: widget.userUid)
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> userOrders = [];

    for (var orderDoc in userOrdersSnapshot.docs) {
      final orderId = orderDoc.id;
      final userOrderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('userOrders')
          .where('orderId', isEqualTo: orderId)
          .where('status', isEqualTo: 4)
          .get();

      userOrders.addAll(userOrderSnapshot.docs);
    }

    return userOrders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Activity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to previous screen
          },
        ),
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        future: fetchUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No orders available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final orderData = snapshot.data![index].data();
                int orderStatus = orderData[
                    'status']; // Assuming 'status' is the key for order status in your 'orderData' map

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderDetailsPage(
                          orderId: orderData['orderId'],
                          userOrderId: orderData['userOrderId'],
                        ),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              orderData['shopName'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              orderStatus == 2
                                  ? 'To Ship'
                                  : orderStatus == 3
                                      ? 'To Receive'
                                      : 'Complete',
                            ),
                          ],
                        ),
                        leading: Image.network(orderData['imageUrl']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Quantity: ${orderData['quantity']}'),
                            Text(
                                'Total Price: RM${orderData['itemTotalPrice'].toStringAsFixed(2)}'),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderData['orderId'])
                                  .collection('userOrders')
                                  .doc(orderData['userOrderId'])
                                  .collection('deliveryMessage')
                                  .orderBy('timestamp', descending: true)
                                  .limit(1)
                                  .snapshots(),
                              builder: (context, deliveryMessageSnapshot) {
                                if (deliveryMessageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (!deliveryMessageSnapshot.hasData ||
                                    deliveryMessageSnapshot
                                        .data!.docs.isEmpty) {
                                  return const SizedBox();
                                } else {
                                  var deliveryMessage = deliveryMessageSnapshot
                                      .data!.docs[0]['message'];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      '$deliveryMessage',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
