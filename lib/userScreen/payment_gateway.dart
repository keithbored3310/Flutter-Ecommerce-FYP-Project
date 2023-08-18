import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final String orderId;
  final String userUid;
  final double totalOrderPrice;

  PaymentGatewayScreen({
    required this.orderId,
    required this.userUid,
    required this.totalOrderPrice,
  });

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Cancel Payment'),
            content: Text('Are you sure you want to cancel the payment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true); // Confirmed cancel
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // Not canceling
                },
                child: Text('No'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }
    // Add more validation logic for card number if needed
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date';
    }
    // Add more validation logic for expiry date if needed
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }
    // Add more validation logic for CVV if needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payment Gateway'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Order Price: RM${widget.totalOrderPrice.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Card Number'),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateCardNumber,
                ),
                SizedBox(height: 20),
                Text('Expiry Date'),
                TextFormField(
                  controller: _expiryDateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateExpiryDate,
                ),
                SizedBox(height: 20),
                Text('CVV'),
                TextFormField(
                  controller: _cvvController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateCvv,
                ),
                Spacer(), // Add space between fields and button
                ElevatedButton(
                  onPressed: () async {
                    // Validate card details (for demonstration purposes)
                    if (_cardNumberController.text.isEmpty ||
                        _expiryDateController.text.isEmpty ||
                        _cvvController.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Validation Error'),
                          content: Text('Please fill in all card details.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // Show a loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    final userOrdersQuerySnapshot = await FirebaseFirestore
                        .instance
                        .collection('orders')
                        .doc(widget.orderId)
                        .collection('userOrders')
                        .where('status', isEqualTo: 1)
                        .where('userId', isEqualTo: widget.userUid)
                        .get();

                    final batch = FirebaseFirestore.instance.batch();

                    // Add orderId to the 'orders' document
                    batch.update(
                      FirebaseFirestore.instance
                          .collection('orders')
                          .doc(widget.orderId),
                      {'orderId': widget.orderId},
                    );

                    for (final userOrderDoc in userOrdersQuerySnapshot.docs) {
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
                          .doc(widget.orderId),
                      {'status': 2},
                    );

                    final userOrdersQuery = FirebaseFirestore.instance
                        .collection('orders')
                        .doc(widget.orderId)
                        .collection('userOrders')
                        .where('status', isEqualTo: 1)
                        .where('userId', isEqualTo: widget.userUid);

                    final userOrdersSnapshot = await userOrdersQuery.get();

                    for (final userOrderDoc in userOrdersSnapshot.docs) {
                      batch.update(userOrderDoc.reference, {
                        'status': 2,
                      });
                    }

                    await batch.commit();

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

                        productQuantityBatch
                            .update(productDocRef, {'quantity': newQuantity});

                        final sellerId = userOrderDoc['sellerId'];
                        final sellerStatisticDocRef = FirebaseFirestore.instance
                            .collection('sellerStatistic')
                            .doc(sellerId);

                        final sellerStatisticData = {
                          'imageUrl': userOrderDoc['imageUrl'],
                          'itemTotalPrice': userOrderDoc['itemTotalPrice'],
                          'productId': productId,
                          'productName': userOrderDoc['productName'],
                          'quantity': quantity,
                        };

                        productQuantityBatch.set(sellerStatisticDocRef,
                            sellerStatisticData, SetOptions(merge: true));
                      }
                    }

                    await productQuantityBatch.commit();

                    final deliveryMessageBatch =
                        FirebaseFirestore.instance.batch();

                    for (final userOrderDoc in userOrdersSnapshot.docs) {
                      final deliveryMessageCollectionRef = FirebaseFirestore
                          .instance
                          .collection('orders')
                          .doc(widget.orderId)
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

                    await deliveryMessageBatch.commit();

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payment successful!'),
                      ),
                    );

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         const DeliveryPage(initialTabIndex: 1),
                    //   ),
                    // );
                  },
                  child: Text('Pay'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
