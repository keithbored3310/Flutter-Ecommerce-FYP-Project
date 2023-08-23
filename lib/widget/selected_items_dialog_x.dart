// import 'package:ecommerce/userScreen/payment_gateway.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SelectedItemsDialog extends StatefulWidget {
//   final List<DocumentSnapshot> selectedItems;
//   final String userUid;
//   final double totalPrice;

//   SelectedItemsDialog({
//     required this.selectedItems,
//     required this.userUid,
//     required this.totalPrice,
//   });

//   @override
//   _SelectedItemsDialogState createState() => _SelectedItemsDialogState();
// }

// class _SelectedItemsDialogState extends State<SelectedItemsDialog> {
//   double totalOrderPrice = 0;
//   int amountOfUserOrders = 0;
//   double shippingFees = 0;
//   double finalPrice = 0;
//   String orderId = '';

//   @override
//   void initState() {
//     super.initState();
//     calculatePrices();
//   }

//   void calculatePrices() {
//     totalOrderPrice = widget.totalPrice;
//     amountOfUserOrders = widget.selectedItems.length;
//     shippingFees = amountOfUserOrders > 5 ? 0 : 5.00;
//     finalPrice = totalOrderPrice + shippingFees;
//   }

//   void proceedToCheckout() async {
//     double totalOrderPrice = widget.totalPrice;

//     // Get user data from Firestore
//     DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(widget.userUid)
//         .get();

//     if (!userDataSnapshot.exists) {
//       return; // User data not found
//     }

//     Map<String, dynamic>? userData = userDataSnapshot.data()
//         as Map<String, dynamic>?; // Cast to the correct type

//     if (userData == null) {
//       return; // User data is not available
//     }

//     String username = userData['username'];
//     String address = userData['address'];
//     String phone = userData['phone'];

//     // Create order document in the orders collection
//     DocumentReference orderRef =
//         await FirebaseFirestore.instance.collection('orders').add({
//       'userId': widget.userUid,
//       'totalOrderPrice': totalOrderPrice,
//       'status': 1, // Status for pending
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//     orderId = orderRef.id;

//     // Iterate through selected items
//     for (var item in widget.selectedItems) {
//       String itemId = item.id;
//       DocumentSnapshot cartItemSnapshot = await FirebaseFirestore.instance
//           .collection('carts')
//           .doc(itemId)
//           .get();

//       // Get product details from the cart item
//       String productId = cartItemSnapshot['productId'];
//       int cartQuantity = cartItemSnapshot['quantity'];
//       double itemDiscountedPrice = cartItemSnapshot['discountedPrice'];
//       String imageUrl = cartItemSnapshot['imageUrl'];
//       String productName = cartItemSnapshot['name'];
//       String sellerId = cartItemSnapshot['sellerId'];

//       // Calculate order details
//       double itemTotalPrice = itemDiscountedPrice * cartQuantity;

//       // Get seller data from Firestore
//       DocumentSnapshot sellerDataSnapshot = await FirebaseFirestore.instance
//           .collection('sellers')
//           .doc(sellerId)
//           .get();

//       if (!sellerDataSnapshot.exists) {
//         return; // Seller data not found
//       }

//       Map<String, dynamic>? sellerData = sellerDataSnapshot.data()
//           as Map<String, dynamic>?; // Cast to the correct type

//       if (sellerData == null) {
//         return; // Seller data is not available
//       }

//       String shopName = sellerData['shopName'];

//       // Create order document in the userOrders subcollection
//       await orderRef.collection('userOrders').add({
//         'orderId': orderId,
//         'productId': productId,
//         'quantity': cartQuantity,
//         'itemTotalPrice': itemTotalPrice,
//         'imageUrl': imageUrl,
//         'productName': productName,
//         'sellerId': sellerId,
//         'userId': widget.userUid,
//         'username': username,
//         'address': address,
//         'phone': phone,
//         'shopName': shopName, // Save shopName
//         'status': 1, // Status for pending
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Save the selected item into the orders collection as well
//       await orderRef.collection('selectedItems').add({
//         'itemId': itemId,
//         'productId': productId,
//         'quantity': cartQuantity,
//         'itemTotalPrice': itemTotalPrice,
//         'imageUrl': imageUrl,
//         'productName': productName,
//         'sellerId': sellerId,
//         'status': 1, // Status for pending
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       // Remove item from cart
//       await FirebaseFirestore.instance.collection('carts').doc(itemId).delete();
//     }
//     print('orderId in the function: $orderId');
//     // Clear selected items
//     setState(() {
//       widget.selectedItems.clear();
//     });
//     print('orderId after the function: $orderId');
//     Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Checkout Page'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           FutureBuilder<DocumentSnapshot>(
//             future: FirebaseFirestore.instance
//                 .collection('users')
//                 .doc(widget.userUid)
//                 .get(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return CircularProgressIndicator();
//               }

//               if (!snapshot.hasData || !snapshot.data!.exists) {
//                 return Text('User not found');
//               }

//               Map<String, dynamic>? userData = snapshot.data!.data()
//                   as Map<String, dynamic>?; // Cast to the correct type
//               if (userData == null) {
//                 return Text('User data not available');
//               }

//               // Display user data using userData
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Username: ${userData['username']}'),
//                   Text('Phone: ${userData['phone']}'),
//                   Text('Address: ${userData['address']}'),
//                 ],
//               );
//             },
//           ),
//           SizedBox(height: 16),
//           Text('Amount of User Orders: $amountOfUserOrders'),
//           Text('Total Order Price: RM${totalOrderPrice.toStringAsFixed(2)}'),
//           Text('Shipping Fees: RM${shippingFees.toStringAsFixed(2)}'),
//           const Divider(),
//           Text('Final Price: RM${finalPrice.toStringAsFixed(2)}'),
//           const Divider(),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: widget.selectedItems.map((item) {
//               return FutureBuilder<DocumentSnapshot>(
//                 future: FirebaseFirestore.instance
//                     .collection('sellers')
//                     .doc(item['sellerId'])
//                     .get(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return CircularProgressIndicator();
//                   }

//                   String shopName =
//                       snapshot.data?['shopName'] ?? 'Unknown Shop';

//                   return ListTile(
//                     leading: Image.network(
//                       item['imageUrl'],
//                       width: 40,
//                       height: 40,
//                       fit: BoxFit.cover,
//                     ),
//                     title: Text(item['name']),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Shop: $shopName'), // Display shop name
//                         Text('Quantity: ${item['quantity']}'),
//                         Text(
//                           'Total Price: RM${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.of(context).pop(); // Close the dialog
//           },
//           child: Text('Close'),
//         ),
//         ElevatedButton(
//           onPressed: () async {
//             proceedToCheckout(); // Use await here
//             print('Order ID: $orderId');
//             if (orderId.isNotEmpty) {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (context) => PaymentGatewayScreen(
//                     orderId: orderId,
//                     userUid: widget.userUid,
//                     totalOrderPrice: totalOrderPrice,
//                   ),
//                 ),
//               );
//             }
//           },
//           child: Text('Pay'),
//         ),
//       ],
//     );
//   }
// }
