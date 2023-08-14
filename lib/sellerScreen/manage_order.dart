import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageOrderPage extends StatefulWidget {
  final String sellerId;

  const ManageOrderPage({required this.sellerId});

  @override
  _ManageOrderPageState createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('userOrders')
            .snapshots(),
        builder: (context, userOrdersSnapshot) {
          if (userOrdersSnapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!userOrdersSnapshot.hasData ||
              userOrdersSnapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No orders available.'),
            );
          } else {
            // Filter the documents based on sellerId
            var matchingOrders =
                userOrdersSnapshot.data!.docs.where((userOrderDoc) {
              String orderSellerId = userOrderDoc['sellerId'];
              return orderSellerId == widget.sellerId;
            }).toList();

            return ListView.builder(
              itemCount: matchingOrders.length,
              itemBuilder: (context, index) {
                var orderData =
                    matchingOrders[index].data() as Map<String, dynamic>;
                String orderId = matchingOrders[index].id;
                String username = orderData['username'];
                String imageUrl = orderData['imageUrl'];
                int quantity = orderData['quantity'];
                String productName = orderData['productName'];
                double itemTotalPrice = orderData['itemTotalPrice'];
                int status = orderData['status'];

                return Column(
                  children: [
                    ListTile(
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.network(imageUrl),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Product: $productName'),
                              Text(
                                  'Total Price: RM${itemTotalPrice.toStringAsFixed(2)}'),
                              Text('Status: ${getStatusText(status)}'),
                              Text('Quantity: $quantity'),
                            ],
                          ),
                          if (status == 2)
                            IconButton(
                              onPressed: () {
                                // Handle ship button click
                                // For example, mark the order as shipped
                              },
                              icon: Icon(Icons.local_shipping),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username: $username'),
                          Text('Order ID: $orderId'),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1, // Adjust the height of the divider as needed
                      color: Colors.grey, // Set the color of the divider
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
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
}
