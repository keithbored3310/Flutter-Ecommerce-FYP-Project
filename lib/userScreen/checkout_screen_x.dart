// import 'package:flutter/material.dart';

// class CheckoutScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedItems;
//   final String userUid;

//   CheckoutScreen({
//     required this.selectedItems,
//     required this.userUid,
//     Key? key,
//   }) : super(key: key);

//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   double totalOrderPrice = 0;

//   @override
//   void initState() {
//     super.initState();
//     calculateTotalOrderPrice();
//   }

//   void calculateTotalOrderPrice() {
//     // Calculate the total order price based on selected items
//     double totalPrice = 0;
//     for (var item in widget.selectedItems) {
//       totalPrice += item['itemTotalPrice'];
//     }
//     setState(() {
//       totalOrderPrice = totalPrice;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Checkout'),
//       ),
//       body: Column(
//         children: [
//           // Display selected items and their details here
//           ListView.builder(
//             itemCount: widget.selectedItems.length,
//             itemBuilder: (context, index) {
//               final item = widget.selectedItems[index];
//               final productId = item['productId'];
//               final quantity = item['quantity'];
//               final itemTotalPrice = item['itemTotalPrice'];

//               return ListTile(
//                 title: Text('Product ID: $productId'),
//                 subtitle: Text('Quantity: $quantity'),
//                 trailing: Text(
//                     'Total Price: RM ${itemTotalPrice.toStringAsFixed(2)}'),
//               );
//             },
//           ),
//           // Display the total order price
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Total Order Price: RM ${totalOrderPrice.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ),
//           // You can add a button here to confirm the order
//         ],
//       ),
//     );
//   }
// }
