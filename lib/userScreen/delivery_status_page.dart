import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/order_confirmation.dart';
import 'package:flutter/material.dart';

class DeliveryStatusPage extends StatelessWidget {
  final String title;
  final String userUid;

  const DeliveryStatusPage({
    required this.title,
    required this.userUid,
    Key? key,
  }) : super(key: key);

  Future<List<String>> fetchOrderIds() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userUid)
        .where('status', isEqualTo: getStatusFromTitle(title))
        .orderBy('timestamp', descending: true)
        .get();

    List<String> orderIds = querySnapshot.docs.map((doc) => doc.id).toList();
    return orderIds;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: fetchOrderIds(),
      builder: (context, orderIdsSnapshot) {
        if (orderIdsSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!orderIdsSnapshot.hasData ||
            orderIdsSnapshot.data!.isEmpty) {
          return Center(
            child: Text('No orders available.'),
          );
        } else {
          List<String> orderIds = orderIdsSnapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'User Orders:',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Column(
                  children: orderIds.map(
                    (orderId) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('orders')
                            .doc(orderId)
                            .collection('userOrders')
                            .where('userId', isEqualTo: userUid)
                            .snapshots(),
                        builder: (context, userOrderSnapshot) {
                          if (userOrderSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (!userOrderSnapshot.hasData ||
                              userOrderSnapshot.data!.docs.isEmpty) {
                            return SizedBox();
                          } else {
                            double totalOrderPrice = 0;

                            List<Widget> userOrderWidgets = [];

                            for (var order in userOrderSnapshot.data!.docs) {
                              totalOrderPrice += order['itemTotalPrice'];
                              userOrderWidgets.add(
                                Column(
                                  children: [
                                    Divider(),
                                    ListTile(
                                      leading: Image.network(order['imageUrl']),
                                      title: Text(order['productName']),
                                      subtitle: Text(
                                        'Quantity: ${order['quantity']}\nTotal Price: RM${order['itemTotalPrice'].toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            int orderStatus =
                                userOrderSnapshot.data!.docs[0]['status'];

                            if (orderStatus == 1) {
                              // Display existing widget for status 1
                              return Column(
                                children: [
                                  ...userOrderWidgets,
                                  SizedBox(height: 20),
                                  Text(
                                    'Total Order Price: RM${totalOrderPrice.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              OrderConfirmationScreen(
                                            orderId: orderId,
                                            userUid: userUid,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text('Pay Now'),
                                  ),
                                ],
                              );
                            } else if (orderStatus == 2 ||
                                orderStatus == 3 ||
                                orderStatus == 4) {
                              // Display grid layout for status 2, 3, 4
                              return Column(
                                children: userOrderSnapshot.data!.docs.map(
                                  (userOrderDoc) {
                                    var shopName = userOrderDoc['shopName'];
                                    return Column(
                                      children: [
                                        Divider(),
                                        ListTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$shopName',
                                                style: TextStyle(
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
                                        ),
                                        Divider(),
                                        ListTile(
                                          leading: Image.network(
                                              userOrderDoc['imageUrl']),
                                          title:
                                              Text(userOrderDoc['productName']),
                                          subtitle: Text(
                                              'Quantity: ${userOrderDoc['quantity']}\nTotal Price: RM${userOrderDoc['itemTotalPrice'].toStringAsFixed(2)}'),
                                        ),
                                        Divider(),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: FirebaseFirestore.instance
                                              .collection('orders')
                                              .doc(orderId)
                                              .collection('userOrders')
                                              .doc(userOrderDoc.id)
                                              .collection('deliveryMessage')
                                              .orderBy('timestamp',
                                                  descending: true)
                                              .limit(1)
                                              .snapshots(),
                                          builder: (context,
                                              deliveryMessageSnapshot) {
                                            if (deliveryMessageSnapshot
                                                    .connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (!deliveryMessageSnapshot
                                                    .hasData ||
                                                deliveryMessageSnapshot
                                                    .data!.docs.isEmpty) {
                                              return SizedBox();
                                            } else {
                                              var deliveryMessage =
                                                  deliveryMessageSnapshot
                                                      .data!.docs[0]['message'];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                child: Text(
                                                  '$deliveryMessage',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        Divider(),
                                        // Add button based on orderStatus
                                      ],
                                    );
                                  },
                                ).toList(),
                              );
                            }

                            return SizedBox(); // Default case
                          }
                        },
                      );
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
