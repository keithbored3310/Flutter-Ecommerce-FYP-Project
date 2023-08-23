import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/userScreen/delivery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

class PaymentGatewayScreen extends StatefulWidget {
  final String orderId;
  final String userUid;

  PaymentGatewayScreen({
    required this.orderId,
    required this.userUid,
  });

  @override
  _PaymentGatewayScreenState createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  TextEditingController _cardNumberController = TextEditingController();
  TextEditingController _expiryDateController = TextEditingController();
  TextEditingController _cvvController = TextEditingController();
  TextEditingController _expiryMonthController = TextEditingController();
  TextEditingController _expiryYearController = TextEditingController();

  Future<void> updateSellerSalesStatistics(String sellerId, double orderTotal,
      List<Map<String, dynamic>> productSales) async {
    final currentDate = DateTime.now();
    final year = currentDate.year;
    final month = currentDate.month;

    final sellerDocReference =
        FirebaseFirestore.instance.collection('sellers').doc(sellerId);
    final sellerSalesDocReference =
        sellerDocReference.collection('sales').doc('$year-$month');

    // Create a new monthly sales document if it doesn't exist
    await sellerSalesDocReference.set({}, SetOptions(merge: true));

    // Fetch the existing sales data
    final existingSalesData =
        (await sellerSalesDocReference.get()).data() as Map<String, dynamic>?;

    dynamic productSalesData = existingSalesData?['productSales'];
    List<Map<String, dynamic>> updatedProductSales = [];

    if (productSalesData is List<dynamic>) {
      // Convert the dynamic list to List<Map<String, dynamic>>
      updatedProductSales = List<Map<String, dynamic>>.from(productSalesData);
    } else {
      // Handle the case where 'productSales' is not a list of maps
    }

    // Iterate through the provided productSales and add/update them in the array
    for (final productSale in productSales) {
      final productId = productSale['productId'];
      final quantity = productSale['quantity'];
      final itemTotalPrice = productSale['itemTotalPrice'];

      // Fetch the productName from the 'products' collection
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productDoc.exists) {
        final productName = productDoc['name'] as String?;
        if (productName != null) {
          // Check if a product with the same ID already exists in the array
          final existingProductIndex = updatedProductSales
              .indexWhere((product) => product['productId'] == productId);

          if (existingProductIndex != -1) {
            // Update quantity and itemTotalPrice if the product already exists in the array
            updatedProductSales[existingProductIndex]['quantity'] += quantity;
            updatedProductSales[existingProductIndex]['itemTotalPrice'] +=
                itemTotalPrice;
          } else {
            // Add the product to the array
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

    // Update the product sales array in Firestore
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
                  Navigator.pop(context, true); // Confirmed cancel
                },
                child: const Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false); // Not canceling
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
    // Additional validation logic for card number (e.g., length or format)
    if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    // You can add more validation rules here, such as checking for valid card formats.
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
    // Additional validation logic for CVV (e.g., length)
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
              // While waiting for data to load, display a loading indicator
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // If an error occurs, display an error message
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              // If no data is available or the document doesn't exist, display a message
              return const Center(child: Text('Order Data Not Found'));
            } else {
              // Data is available, display the payment information
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
                        ),
                        validator: _validateCardNumber,
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
                                LengthLimitingTextInputFormatter(
                                    2), // Limit to 2 characters (MM)
                              ],
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'MM',
                              ),
                              validator: _validateExpiryMonth,
                            ),
                          ),
                          SizedBox(
                              width: 10), // Add some spacing between MM and YY
                          Expanded(
                            child: TextFormField(
                              controller: _expiryYearController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(
                                    2), // Limit to 2 characters (YY)
                              ],
                              decoration: InputDecoration(
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
                          // Validate card details
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
                            // Display validation errors in a dialog
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
                            // Payment logic - All data is valid
                            // Clear the text fields
                            _cardNumberController.text = '';
                            _expiryDateController.text = '';
                            _cvvController.text = '';
                            // Show loading dialog
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

                            // Commit the updates to 'orders' and 'userOrders'
                            await batch.commit();

                            // Deduct product quantities and update seller statistics
                            final productQuantityBatch =
                                FirebaseFirestore.instance.batch();

                            for (final userOrderDoc
                                in userOrdersSnapshot.docs) {
                              final productId = userOrderDoc['productId'];
                              final quantity = userOrderDoc['quantity'];
                              print('productId: $productId');
                              print('quantity: $quantity');
                              final productDocRef = FirebaseFirestore.instance
                                  .collection('products')
                                  .doc(productId);
                              final productDoc = await productDocRef.get();

                              // Inside your Flutter code where you process orders
                              // Inside your Flutter code where you process orders
                              // Inside your Flutter code where you process orders
                              if (productDoc.exists) {
                                final currentQuantity = productDoc['quantity'];
                                final newQuantity = currentQuantity - quantity;
                                print('currentQuantity: $currentQuantity');
                                print('newQuantity: $newQuantity');
                                productQuantityBatch.update(
                                    productDocRef, {'quantity': newQuantity});

                                final sellerId = userOrderDoc['sellerId'];

                                // Create a List<Map<String, dynamic>> from productSales
                                List<Map<String, dynamic>> productSalesList = [
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

                            // Commit the updates to product quantities and seller statistics
                            await productQuantityBatch.commit();

                            // Update 'deliveryMessage' in 'userOrders'
                            // Update 'deliveryMessage' in 'userOrders'
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

                            // Close the loading dialog
                            Navigator.pop(context);

                            // Show a success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Payment successful!'),
                              ),
                            );

                            // Navigate to a new page (DeliveryPage in this case)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DeliveryPage(initialTabIndex: 1),
                              ),
                            );
                          }
                        },
                        child: Text('Pay'),
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
      final newText =
          '0$text'; // Automatically adds '0' for months like '6' to become '06'
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else if (text.length == 2 && text[1] != '/') {
      // If there are two digits and no '/', add a '/' after the second digit
      final newText = '$text/';
      return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    return newValue;
  }
}
