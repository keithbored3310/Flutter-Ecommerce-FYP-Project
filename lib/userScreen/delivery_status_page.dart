import 'package:ecommerce/userScreen/delivery_page.dart';
import 'package:ecommerce/userScreen/review_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/order_confirmation.dart';
import 'package:ecommerce/userScreen/order_detail_page.dart';

class DeliveryStatusPage extends StatefulWidget {
  final String title;
  final String userUid;

  const DeliveryStatusPage({
    required this.title,
    required this.userUid,
    super.key,
  });

  @override
  State<DeliveryStatusPage> createState() => _DeliveryStatusPageState();
}

class _DeliveryStatusPageState extends State<DeliveryStatusPage>
    with AutomaticKeepAliveClientMixin<DeliveryStatusPage> {
  late List<Map<String, dynamic>> userOrdersData;

  @override
  void initState() {
    super.initState();
    fetchUserOrders();
  }

  Future<void> fetchUserOrders() async {
    userOrdersData = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: widget.userUid)
        .get();

    for (var orderDoc in querySnapshot.docs) {
      String orderId = orderDoc.id;

      QuerySnapshot userOrdersQuerySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('userOrders')
          .where('userId', isEqualTo: widget.userUid)
          .get();

      userOrdersData.addAll(userOrdersQuerySnapshot.docs.map((userOrderDoc) {
        return userOrderDoc.data() as Map<String, dynamic>;
      }));
    }

    if (mounted) {
      setState(() {
        // Update the UI after fetching user orders
      });
    }
  }

  Future<List<DocumentSnapshot>> fetchOrdersAndUserOrders(int status) async {
    List<DocumentSnapshot> ordersAndUserOrders = [];

    if (status == 1) {
      // Fetch the document IDs of orders that match the criteria
      QuerySnapshot orderIdsQuerySnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: widget.userUid)
          .get();

      // Fetch userOrders using the retrieved order IDs
      for (var orderDoc in orderIdsQuerySnapshot.docs) {
        String orderId = orderDoc.id;

        QuerySnapshot userOrdersQuerySnapshot = await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .collection('userOrders')
            .where('userId', isEqualTo: widget.userUid)
            .where('status', isEqualTo: status)
            .orderBy('timestamp', descending: true)
            .get();

        ordersAndUserOrders.addAll(userOrdersQuerySnapshot.docs);
      }
    } else {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('userOrders')
          .where('userId', isEqualTo: widget.userUid)
          .where('status', isEqualTo: status)
          .orderBy('timestamp', descending: true)
          .get();

      ordersAndUserOrders.addAll(querySnapshot.docs);
    }
    return ordersAndUserOrders;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<List<DocumentSnapshot>>(
      future: fetchOrdersAndUserOrders(getStatusFromTitle(widget.title)),
      builder: (context, ordersAndUserOrdersSnapshot) {
        if (ordersAndUserOrdersSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(), // Wrap in Center
          );
        } else if (!ordersAndUserOrdersSnapshot.hasData ||
            ordersAndUserOrdersSnapshot.data!.isEmpty) {
          return const Center(
            child: Text('No orders available.', style: TextStyle(fontSize: 20)),
          );
        } else {
          List<DocumentSnapshot> ordersAndUserOrders =
              ordersAndUserOrdersSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'User Orders:',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Column(
                  children: ordersAndUserOrders.map(
                    (orderOrUserOrder) {
                      var data =
                          orderOrUserOrder.data() as Map<String, dynamic>;
                      int orderStatus = data['status'];

                      if (orderStatus == 1) {
                        String orderId = data['orderId'] as String;

                        return ListTile(
                          leading: Image.network(data['imageUrl']),
                          title: Text(data['productName']),
                          subtitle: Text(
                            'Quantity: ${data['quantity']}\nTotal Price: RM${data['itemTotalPrice'].toStringAsFixed(2)}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderConfirmationScreen(
                                    orderId: orderId,
                                    userUid: widget.userUid,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Pay Now'),
                          ),
                        );
                      } else {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderDetailsPage(
                                  orderId: data['orderId'],
                                  userOrderId: data['userOrderId'],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      data['shopName'],
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
                                leading: Image.network(data['imageUrl']),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quantity: ${data['quantity']}',
                                    ),
                                    Text(
                                      'Total Price: RM${data['itemTotalPrice'].toStringAsFixed(2)}',
                                    ),
                                    StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('orders')
                                          .doc(data['orderId'])
                                          .collection('userOrders')
                                          .doc(orderOrUserOrder.id)
                                          .collection('deliveryMessage')
                                          .orderBy('timestamp',
                                              descending: true)
                                          .limit(1)
                                          .snapshots(),
                                      builder:
                                          (context, deliveryMessageSnapshot) {
                                        if (deliveryMessageSnapshot
                                                .connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child:
                                                CircularProgressIndicator(), // Wrap in Center
                                          );
                                        } else if (!deliveryMessageSnapshot
                                                .hasData ||
                                            deliveryMessageSnapshot
                                                .data!.docs.isEmpty) {
                                          return const SizedBox();
                                        } else {
                                          var deliveryMessage =
                                              deliveryMessageSnapshot
                                                  .data!.docs[0]['message'];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
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
                              if (orderStatus == 3)
                                ElevatedButton(
                                  onPressed: () async {
                                    // Update the status in the userOrders subcollection to 4
                                    await FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(data[
                                            'orderId']) // Use the orderId to access the order document
                                        .collection('userOrders')
                                        .doc(orderOrUserOrder
                                            .id) // Use the userOrderId to access the userOrder document
                                        .update({'status': 4});

                                    // You might want to add additional code here if needed
                                    await FirebaseFirestore.instance
                                        .collection('reviews')
                                        .add({
                                      'userId': data['userId'],
                                      'orderId': data['orderId'],
                                      'userOrderId': data['userOrderId'],
                                      'username': data['username'],
                                      'imageUrl': data['imageUrl'],
                                      'productName': data['productName'],
                                      'sellerId': data['sellerId'],
                                      'shopname': data['shopName'],
                                      'timestamp': data['timestamp'],
                                      'status': data['status'],
                                      'quantity': data['quantity'],
                                      'productId': data['productId'],
                                      'orderReceived': true,
                                    });

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DeliveryPage(
                                                initialTabIndex: 3),
                                      ),
                                    );
                                  },
                                  child: const Text('Order Received'),
                                ),
                              if (orderStatus == 4 &&
                                  !(data['isRated'] ?? false))
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReviewPage(
                                          orderId: data['orderId'],
                                          userOrderId: data['userOrderId'],
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Rate'),
                                ),
                            ],
                          ),
                        );
                      }
                    },
                  ).toList(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  int getStatusFromTitle(String title) {
    switch (title) {
      case 'To Pay':
        return 1;
      case 'To Ship':
        return 2;
      case 'To Receive':
        return 3;
      case 'Complete':
        return 4;
      default:
        return 0;
    }
  }
}
