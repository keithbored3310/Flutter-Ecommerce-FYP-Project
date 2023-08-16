import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;
  final String userUid;

  OrderConfirmationScreen({required this.orderId, required this.userUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userUid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text('User data not available.'));
          } else {
            var userData = userSnapshot.data!.data() as Map<String, dynamic>;
            String username = userData['username'];
            String address = userData['address'];
            String phone = userData['phone'];

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .doc(orderId)
                  .collection('userOrders')
                  .where('status', isEqualTo: 1)
                  .where('userId', isEqualTo: userUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No orders available.'));
                } else {
                  double totalOrderPrice = 0;
                  int amountOfUserOrders = snapshot.data!.docs.length;

                  for (var order in snapshot.data!.docs) {
                    totalOrderPrice += order['itemTotalPrice'];
                  }

                  double shippingFees = amountOfUserOrders > 5 ? 0 : 5.00;
                  double finalPrice = totalOrderPrice + shippingFees;

                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      Text('Shipping Details', style: TextStyle(fontSize: 20)),
                      Text('Username: $username'),
                      Text('Address: $address'),
                      Text('Phone: $phone'),
                      Divider(),
                      Text('User Orders:', style: TextStyle(fontSize: 20)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snapshot.data!.docs.map((order) {
                          String productName = order['productName'];
                          int quantity = order['quantity'];
                          double itemTotalPrice = order['itemTotalPrice'];
                          String productImageUrl = order['imageUrl'];
                          String sellerId = order['sellerId']; // Fetch sellerId

                          // Fetch shopName from sellers collection using the sellerId
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('sellers')
                                .doc(sellerId)
                                .get(),
                            builder: (context, sellerSnapshot) {
                              if (sellerSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (!sellerSnapshot.hasData ||
                                  !sellerSnapshot.data!.exists) {
                                return ListTile(
                                  title: Text('Product: $productName'),
                                  subtitle: Text(
                                      'Quantity: $quantity\nTotal Price: RM${itemTotalPrice.toStringAsFixed(2)}'),
                                  leading: Image.network(productImageUrl),
                                );
                              } else {
                                String shopName =
                                    sellerSnapshot.data!['shopName'];
                                return ListTile(
                                  title: Text('Product: $productName'),
                                  subtitle: Text(
                                      'Shop: $shopName\nQuantity: $quantity\nTotal Price: RM${itemTotalPrice.toStringAsFixed(2)}'),
                                  leading: Image.network(productImageUrl),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Text('Amount of User Orders: $amountOfUserOrders'),
                      Text(
                          'Total Order Price: RM${totalOrderPrice.toStringAsFixed(2)}'),
                      Text(
                          'Shipping Fees: RM${shippingFees.toStringAsFixed(2)}'),
                      Divider(),
                      Text('Final Price: RM${finalPrice.toStringAsFixed(2)}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final userOrdersQuerySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(orderId)
                                  .collection('userOrders')
                                  .where('status', isEqualTo: 1)
                                  .where('userId', isEqualTo: userUid)
                                  .get();

                          final batch = FirebaseFirestore.instance.batch();

                          // Add orderId to the 'orders' document
                          batch.update(
                            FirebaseFirestore.instance
                                .collection('orders')
                                .doc(orderId),
                            {'orderId': orderId},
                          );

                          for (final userOrderDoc
                              in userOrdersQuerySnapshot.docs) {
                            final userOrderId = userOrderDoc.id;

                            // Update the userOrder document with a new field 'userOrderId'
                            batch.update(
                              userOrderDoc.reference,
                              {'userOrderId': userOrderId},
                            );
                          }

                          batch.update(
                            FirebaseFirestore.instance
                                .collection('orders')
                                .doc(orderId),
                            {'status': 2},
                          );

                          final userOrdersQuery = FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .collection('userOrders')
                              .where('status', isEqualTo: 1)
                              .where('userId', isEqualTo: userUid);

                          final userOrdersSnapshot =
                              await userOrdersQuery.get();

                          for (final userOrderDoc in userOrdersSnapshot.docs) {
                            // Fetch shopName for each product's sellerId
                            final sellerId = userOrderDoc['sellerId'];
                            final sellerSnapshot = await FirebaseFirestore
                                .instance
                                .collection('sellers')
                                .doc(sellerId)
                                .get();

                            final shopName = sellerSnapshot['shopName'];

                            batch.update(userOrderDoc.reference, {
                              'status': 2,
                              'username': username,
                              'address': address,
                              'phone': phone,
                              'shopName': shopName,
                            });
                          }

                          // Commit the updates to 'orders' and 'userOrders'
                          await batch.commit();

                          // Deduct product quantities and update seller statistics
                          final productQuantityBatch =
                              FirebaseFirestore.instance.batch();

                          for (final userOrderDoc in userOrdersSnapshot.docs) {
                            final productId = userOrderDoc['productId'];
                            final quantity = userOrderDoc['quantity'];

                            final productDocRef = FirebaseFirestore.instance
                                .collection('products')
                                .doc(productId);
                            final productDoc = await productDocRef.get();

                            if (productDoc.exists) {
                              final currentQuantity = productDoc['quantity'];
                              final newQuantity = currentQuantity - quantity;

                              productQuantityBatch.update(
                                  productDocRef, {'quantity': newQuantity});

                              final sellerId = userOrderDoc['sellerId'];
                              final sellerStatisticDocRef = FirebaseFirestore
                                  .instance
                                  .collection('sellerStatistic')
                                  .doc(sellerId);

                              final sellerStatisticData = {
                                'imageUrl': userOrderDoc['imageUrl'],
                                'itemTotalPrice':
                                    userOrderDoc['itemTotalPrice'],
                                'productId': productId,
                                'productName': userOrderDoc['productName'],
                                'quantity': quantity,
                              };

                              productQuantityBatch.set(sellerStatisticDocRef,
                                  sellerStatisticData, SetOptions(merge: true));
                            }
                          }

                          // Commit the updates to product quantities and seller statistics
                          await productQuantityBatch.commit();

                          // Update 'deliveryMessage' in 'userOrders'
                          // Update 'deliveryMessage' in 'userOrders'
                          final deliveryMessageBatch =
                              FirebaseFirestore.instance.batch();

                          for (final userOrderDoc in userOrdersSnapshot.docs) {
                            final deliveryMessageCollectionRef =
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(orderId)
                                    .collection('userOrders')
                                    .doc(userOrderDoc.id)
                                    .collection('deliveryMessage')
                                    .doc(); // Generate a new document ID

                            final messageData = {
                              'timestamp': FieldValue.serverTimestamp(),
                              'message': 'Seller is preparing the parcel.',
                            };

                            deliveryMessageBatch.set(
                                deliveryMessageCollectionRef, messageData);
                          }

                          // Commit the updates to 'deliveryMessage'
                          await deliveryMessageBatch.commit();

                          // Navigate back to TabsScreen
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        },
                        child: Text('Pay'),
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
