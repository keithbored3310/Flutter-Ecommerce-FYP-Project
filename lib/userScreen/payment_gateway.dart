import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/userScreen/delivery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final String orderId;
  final String userUid;

  const PaymentGatewayScreen({
    super.key,
    required this.orderId,
    required this.userUid,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryMonthController = TextEditingController();
  final TextEditingController _expiryYearController = TextEditingController();

  Future<void> updateSellerSalesStatistics(String sellerId, double orderTotal,
      List<Map<String, dynamic>> productSales) async {
    final currentDate = DateTime.now();
    final year = currentDate.year;
    final month = currentDate.month;

    final sellerDocReference =
        FirebaseFirestore.instance.collection('sellers').doc(sellerId);
    final sellerSalesDocReference =
        sellerDocReference.collection('sales').doc('$year-$month');
    await sellerSalesDocReference.set({}, SetOptions(merge: true));
    final existingSalesData =
        (await sellerSalesDocReference.get()).data() as Map<String, dynamic>?;

    dynamic productSalesData = existingSalesData?['productSales'];
    List<Map<String, dynamic>> updatedProductSales = [];

    if (productSalesData is List<dynamic>) {
      updatedProductSales = List<Map<String, dynamic>>.from(productSalesData);
    } else {}
    for (final productSale in productSales) {
      final productId = productSale['productId'];
      final quantity = productSale['quantity'];
      final itemTotalPrice = productSale['itemTotalPrice'];
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final productName = productDoc['name'] as String?;
        if (productName != null) {
          final existingProductIndex = updatedProductSales
              .indexWhere((product) => product['productId'] == productId);

          if (existingProductIndex != -1) {
            updatedProductSales[existingProductIndex]['quantity'] += quantity;
            updatedProductSales[existingProductIndex]['itemTotalPrice'] +=
                itemTotalPrice;
          } else {
            updatedProductSales.add({
              'productId': productId,
              'quantity': quantity,
              'itemTotalPrice': itemTotalPrice,
              'productName': productName,
            });
          }
        }
      }
    }
    await sellerSalesDocReference
        .set({'productSales': updatedProductSales}, SetOptions(merge: true));
  }

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
            title: const Text('Cancel Payment'),
            content: const Text('Are you sure you want to cancel the payment?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: const Text('No'),
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
    if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? _validateExpiryMonth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the month (MM)';
    }
    final month = int.tryParse(value);
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month (MM)';
    }
    return null;
  }

  String? _validateExpiryYear(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the year (YY)';
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Invalid year (YY)';
    }
    final currentYear = DateTime.now().year % 100;
    if (year < currentYear) {
      return 'Card has expired';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }
    if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _showExitConfirmationDialog,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Gateway'),
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('orders')
              .doc(widget.orderId)
              .get(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Order Data Not Found'));
            } else {
              final orderData = snapshot.data!.data() as Map<String, dynamic>;
              final double finalPrice = orderData['finalPrice'];

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text('Order ID: ${widget.orderId}'),
                      Text('User ID: ${widget.userUid}'),
                      Text(
                        'Total Order Price: RM${finalPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 20),
                      const Text('Card Number'),
                      TextFormField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          counter: Text('Max 16 digits'),
                        ),
                        validator: _validateCardNumber,
                        maxLength: 16,
                      ),
                      const SizedBox(height: 20),
                      const Text('Expiry Date'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryMonthController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'MM',
                              ),
                              validator: _validateExpiryMonth,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _expiryYearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'YY',
                              ),
                              validator: _validateExpiryYear,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('CVV'),
                      TextFormField(
                        controller: _cvvController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateCvv,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          String? cardNumberError =
                              _validateCardNumber(_cardNumberController.text);
                          String? expiryMonthError =
                              _validateExpiryMonth(_expiryMonthController.text);
                          String? expiryYearError =
                              _validateExpiryYear(_expiryYearController.text);
                          String? cvvError = _validateCvv(_cvvController.text);

                          if (cardNumberError != null ||
                              expiryMonthError != null ||
                              expiryYearError != null ||
                              cvvError != null) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Validation Error'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (cardNumberError != null)
                                      Text(cardNumberError),
                                    if (expiryMonthError != null ||
                                        expiryYearError != null)
                                      Text(
                                          '$expiryMonthError $expiryYearError'),
                                    if (cvvError != null) Text(cvvError),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            final expiryMonth =
                                int.parse(_expiryMonthController.text);
                            final expiryYear =
                                int.parse(_expiryYearController.text);
                            final currentYear = DateTime.now().year % 100;
                            final currentMonth = DateTime.now().month;

                            if (expiryYear < currentYear ||
                                (expiryYear == currentYear &&
                                    expiryMonth < currentMonth)) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Card Expired'),
                                  content: const Text(
                                      'The card has already expired.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              _cardNumberController.text = '';
                              _expiryDateController.text = '';
                              _cvvController.text = '';
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              final userOrdersQuerySnapshot =
                                  await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(widget.orderId)
                                      .collection('userOrders')
                                      .where('status', isEqualTo: 1)
                                      .where('userId',
                                          isEqualTo: widget.userUid)
                                      .get();

                              final batch = FirebaseFirestore.instance.batch();
                              batch.update(
                                FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(widget.orderId),
                                {'orderId': widget.orderId},
                              );

                              for (final userOrderDoc
                                  in userOrdersQuerySnapshot.docs) {
                                final userOrderId = userOrderDoc.id;
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

                              final userOrdersSnapshot =
                                  await userOrdersQuery.get();

                              for (final userOrderDoc
                                  in userOrdersSnapshot.docs) {
                                batch.update(userOrderDoc.reference, {
                                  'status': 2,
                                });
                              }
                              await batch.commit();
                              final productQuantityBatch =
                                  FirebaseFirestore.instance.batch();

                              for (final userOrderDoc
                                  in userOrdersSnapshot.docs) {
                                final productId = userOrderDoc['productId'];
                                final quantity = userOrderDoc['quantity'];
                                final productDocRef = FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(productId);
                                final productDoc = await productDocRef.get();
                                if (productDoc.exists) {
                                  final currentQuantity =
                                      productDoc['quantity'];
                                  final newQuantity =
                                      currentQuantity - quantity;
                                  productQuantityBatch.update(
                                      productDocRef, {'quantity': newQuantity});

                                  final sellerId = userOrderDoc['sellerId'];

                                  List<Map<String, dynamic>> productSalesList =
                                      [
                                    {
                                      'productId': productId.toString(),
                                      'quantity': quantity,
                                      'itemTotalPrice':
                                          userOrderDoc['itemTotalPrice'],
                                    },
                                  ];

                                  await updateSellerSalesStatistics(
                                      sellerId,
                                      userOrderDoc['itemTotalPrice'],
                                      productSalesList);
                                }
                              }
                              await productQuantityBatch.commit();
                              final deliveryMessageBatch =
                                  FirebaseFirestore.instance.batch();

                              for (final userOrderDoc
                                  in userOrdersSnapshot.docs) {
                                final deliveryMessageCollectionRef =
                                    FirebaseFirestore.instance
                                        .collection('orders')
                                        .doc(widget.orderId)
                                        .collection('userOrders')
                                        .doc(userOrderDoc.id)
                                        .collection('deliveryMessage')
                                        .doc();

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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DeliveryPage(initialTabIndex: 1),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Pay'),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.length == 1 && text != '0' && text != '1') {
      final newText = '0$text';
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else if (text.length == 2 && text[1] != '/') {
      final newText = '$text/';
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}
