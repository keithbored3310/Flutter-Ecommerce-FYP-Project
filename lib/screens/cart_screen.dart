import 'package:ecommerce/userScreen/payment_gateway.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userUid;
  late Stream<QuerySnapshot> cartItemsStream;
  List<String> selectedItems = [];

  Map<String, dynamic> productData = {}; // Variable to store product data
  int maxQuantity = 0; // Variable to store max quantity
  late TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserUid();
    _quantityController = TextEditingController();
  }

  Future<void> fetchUserUid() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userUid = user.uid;
      });
      initializeCartItemsStream();
    }
  }

  void initializeCartItemsStream() {
    cartItemsStream = FirebaseFirestore.instance
        .collection('carts')
        .where('userId', isEqualTo: userUid)
        .snapshots();
  }

  void toggleItemSelection(String itemId) {
    setState(() {
      if (selectedItems.contains(itemId)) {
        selectedItems.remove(itemId);
      } else {
        selectedItems.add(itemId);
      }
    });
  }

  bool isItemSelected(String itemId) {
    return selectedItems.contains(itemId);
  }

  double calculateTotalPrice(List<DocumentSnapshot> items) {
    double total = 0;
    for (var item in items) {
      if (selectedItems.contains(item.id)) {
        total += item['discountedPrice'] * item['quantity'];
      }
    }
    return total;
  }

  Future<void> updateCartItemQuantity(String itemId, int newQuantity) async {
    DocumentSnapshot cartItemSnapshot =
        await FirebaseFirestore.instance.collection('carts').doc(itemId).get();

    String productId =
        cartItemSnapshot['productId']; // Get the productId from the cart item

    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId) // Use the productId to fetch the product document
        .get();

    if (productSnapshot.exists) {
      int maxAvailableQuantity = productSnapshot['quantity'];

      if (newQuantity > maxAvailableQuantity) {
        newQuantity = maxAvailableQuantity;
      }

      if (newQuantity > 0) {
        FirebaseFirestore.instance
            .collection('carts')
            .doc(itemId)
            .update({'quantity': newQuantity});
      } else {
        FirebaseFirestore.instance.collection('carts').doc(itemId).delete();
      }
    } else {
      print('Product document does not exist.');
    }
  }

  Future<void> _fetchProductDataAndMaxQuantity(
      String productId, int cartQuantity) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      Map<dynamic, dynamic> productDataMap =
          productSnapshot.data() as Map<dynamic, dynamic>;

      setState(() {
        productData = Map<String, dynamic>.from(productDataMap);
        maxQuantity = productSnapshot['quantity'] ?? 0;

        // Set the initial value for the quantity controller
        _quantityController.text = cartQuantity.toString();
      });
    } catch (e) {
      // Handle error fetching data
      print('Error fetching product data: $e');
    }
  }

  // Define a function to show the checkout dialog
  void showCheckoutDialog() async {
    try {
      // Fetch the selected items from Firestore
      final List<DocumentSnapshot> selectedItemsDocs =
          await fetchSelectedItemsFromFirestore(selectedItems);

      showDialog(
        context: context,
        builder: (context) => CheckoutDialog(
          selectedItems: selectedItemsDocs,
          userUid: userUid,
        ),
      );
    } catch (e) {
      print('Error fetching selected items: $e');
    }
  }

  Future<List<DocumentSnapshot>> fetchSelectedItemsFromFirestore(
      List<String> selectedItems) async {
    final List<Future<DocumentSnapshot>> futures = selectedItems.map((itemId) {
      return FirebaseFirestore.instance.collection('carts').doc(itemId).get();
    }).toList();

    final List<DocumentSnapshot> selectedItemsDocs = await Future.wait(futures);

    return selectedItemsDocs;
  }

  // void proceedToCheckout(QuerySnapshot<Object?> snapshot) async {
  //   double totalOrderPrice = calculateTotalPrice(snapshot.docs);

  //   // Create order document in the orders collection
  //   DocumentReference orderRef =
  //       await FirebaseFirestore.instance.collection('orders').add({
  //     'userId': userUid,
  //     'totalOrderPrice': totalOrderPrice, // Added totalOrderPrice
  //     'status': 1, // Status for pending
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });
  //   String orderId = orderRef.id;
  //   // Iterate through selected items
  //   for (var itemId in selectedItems) {
  //     DocumentSnapshot cartItemSnapshot = await FirebaseFirestore.instance
  //         .collection('carts')
  //         .doc(itemId)
  //         .get();

  //     // Get product details from the cart item
  //     String productId = cartItemSnapshot['productId'];
  //     int cartQuantity = cartItemSnapshot['quantity'];
  //     double itemDiscountedPrice = cartItemSnapshot['discountedPrice'];
  //     String imageUrl = cartItemSnapshot['imageUrl'];
  //     String productName = cartItemSnapshot['name'];
  //     String sellerId = cartItemSnapshot['sellerId'];

  //     // Calculate order details
  //     double itemTotalPrice = itemDiscountedPrice * cartQuantity;

  //     // Create order document in the userOrders subcollection
  //     await orderRef.collection('userOrders').add({
  //       'orderId': orderId,
  //       'productId': productId,
  //       'quantity': cartQuantity,
  //       'itemTotalPrice': itemTotalPrice,
  //       'imageUrl': imageUrl,
  //       'productName': productName,
  //       'sellerId': sellerId,
  //       'userId': userUid,
  //       'status': 1, // Status for pending
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });

  //     // Remove item from cart
  //     await FirebaseFirestore.instance.collection('carts').doc(itemId).delete();
  //   }

  //   // Clear selected items
  //   setState(() {
  //     selectedItems.clear();
  //   });

  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => OrderConfirmationScreen(
  //         orderId: orderRef.id,
  //         userUid: userUid,
  //       ),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child:
                  Text('No items in the cart.', style: TextStyle(fontSize: 20)),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data!.docs[index];
                      String itemId = item.id;
                      String productId =
                          item['productId']; // Get productId from cart item

                      int cartQuantity = item['quantity'];
                      double itemDiscountedPrice = item['discountedPrice'];
                      _fetchProductDataAndMaxQuantity(productId, cartQuantity);
                      return ListTile(
                        onTap: () async {
                          // Fetch product data before navigating to the details screen
                          await _fetchProductDataAndMaxQuantity(
                              productId, cartQuantity);

                          // Now navigate to the details screen with the correct data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsUserScreen(
                                productId: productId,
                                productData: productData,
                                maxQuantity: maxQuantity,
                              ),
                            ),
                          );
                        },
                        leading: Checkbox(
                          value: isItemSelected(itemId),
                          onChanged: (value) {
                            toggleItemSelection(itemId);
                          },
                        ),
                        title: Row(
                          children: [
                            Image.network(
                              item['imageUrl'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 10),
                            Text(item['name']),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                    'Discounted Price: RM${(itemDiscountedPrice * cartQuantity).toStringAsFixed(2)}'),
                                const Spacer(), // Add spacer for alignment
                                IconButton(
                                  icon: const Icon(Icons.remove_shopping_cart),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('carts')
                                        .doc(itemId)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text('Quantity: '),
                                QuantityAdjustment(
                                  initialQuantity: cartQuantity,
                                  maxQuantity: maxQuantity,
                                  onQuantityChanged: (newQuantity) {
                                    updateCartItemQuantity(itemId, newQuantity);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                BottomAppBar(
                  elevation: 6,
                  child: SizedBox(
                    height: 56 + 12, // Increased height by 12 pixels
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: selectedItems.length ==
                                  snapshot.data!.docs.length,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedItems = snapshot.data!.docs
                                        .map((item) => item.id)
                                        .toList();
                                  } else {
                                    selectedItems.clear();
                                  }
                                });
                              },
                            ),
                            const Text('Select All'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Price:',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'RM ${calculateTotalPrice(snapshot.data!.docs).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: selectedItems.isNotEmpty
                              ? () {
                                  showCheckoutDialog(); // Open the dialog to refresh order details
                                }
                              : null,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

class QuantityAdjustment extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;

  const QuantityAdjustment({
    required this.initialQuantity,
    required this.maxQuantity,
    required this.onQuantityChanged,
    super.key,
  });

  @override
  State<QuantityAdjustment> createState() => _QuantityAdjustmentState();
}

class _QuantityAdjustmentState extends State<QuantityAdjustment> {
  late int _currentQuantity;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            setState(() {
              if (_currentQuantity > 1) {
                _currentQuantity--;
                widget.onQuantityChanged(_currentQuantity);
              }
            });
          },
        ),
        SizedBox(
          width: 50, // Adjust the width to your preference
          child: TextField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            controller:
                TextEditingController(text: _currentQuantity.toString()),
            onTap: () {
              // Select all text when the field is tapped
              TextEditingController().selection = TextSelection(
                baseOffset: 0,
                extentOffset: TextEditingController().text.length,
              );
            },
            onChanged: (newValue) {
              int newQuantity = int.tryParse(newValue) ?? _currentQuantity;
              newQuantity = newQuantity.clamp(1, widget.maxQuantity);
              setState(() {
                _currentQuantity = newQuantity;
                widget.onQuantityChanged(_currentQuantity);
              });
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              if (_currentQuantity < widget.maxQuantity) {
                _currentQuantity++;
                widget.onQuantityChanged(_currentQuantity);
              }
            });
          },
        ),
      ],
    );
  }
}

class CheckoutDialog extends StatefulWidget {
  final List<DocumentSnapshot> selectedItems;
  final String userUid;

  const CheckoutDialog({
    required this.selectedItems,
    required this.userUid,
  });

  @override
  _CheckoutDialogState createState() => _CheckoutDialogState();
}

class _CheckoutDialogState extends State<CheckoutDialog> {
  late String username = '';
  late String address = '';
  late String phone = '';
  late double totalOrderPrice;
  late int amountOfUserOrders;
  late double shippingFees;
  late double finalPrice;

  @override
  void initState() {
    super.initState();

    // Fetch user information
    fetchUserInfo();

    // Calculate order details
    totalOrderPrice = calculateTotalPrice();
    amountOfUserOrders = widget.selectedItems.length;
    shippingFees = amountOfUserOrders > 5 ? 0 : 5.00;
    finalPrice = totalOrderPrice + shippingFees;
  }

  void refreshOrderDetails() {
    setState(() {
      totalOrderPrice = calculateTotalPrice();
      amountOfUserOrders = widget.selectedItems.length;
      shippingFees = amountOfUserOrders > 5 ? 0 : 5.00;
      finalPrice = totalOrderPrice + shippingFees;
    });
  }

  void fetchUserInfo() async {
    try {
      // Fetch user information from Firestore using widget.userUid
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userUid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          username = userSnapshot['username'];
          address = userSnapshot['address'];
          phone = userSnapshot['phone'];
        });

        // After setting user information, refresh order details
        refreshOrderDetails();
      } else {
        // Handle the case where the user document doesn't exist
        print('User document does not exist.');
      }
    } catch (e) {
      // Handle any errors that occur during the fetch
      print('Error fetching user information: $e');
    }
  }

  // Calculate the total order price based on selected items
  double calculateTotalPrice() {
    double total = 0;
    for (var item in widget.selectedItems) {
      total += item['discountedPrice'] * item['quantity'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Shipping Details'),
      content: SingleChildScrollView(
        // Wrap content with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: $username'),
            Text('Address: $address'),
            Text('Phone: $phone'),
            SizedBox(height: 16),
            Text('Selected Items:'),
            for (var item in widget.selectedItems)
              ListTile(
                leading: Image.network(item['imageUrl']),
                title: Text(item['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display shopName above quantity
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('sellers')
                          .doc(item['sellerId'])
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var sellerData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String shopName = sellerData['shopName'];
                            return Text('Shop: $shopName');
                          } else {
                            return Text(
                                'Shop: N/A'); // Handle case where seller data doesn't exist
                          }
                        } else {
                          return Text(
                              'Shop: Loading...'); // Handle loading state
                        }
                      },
                    ),
                    Text('Quantity: ${item['quantity']}'),
                    Text(
                      'Price: RM ${(item['discountedPrice'] * item['quantity']).toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            Text('Amount of User Orders: $amountOfUserOrders'),
            Text('Shipping Fees: RM ${shippingFees.toStringAsFixed(2)}'),
            Text('Total Price: RM ${totalOrderPrice.toStringAsFixed(2)}'),
            Text('Final Price: RM ${finalPrice.toStringAsFixed(2)}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              // Calculate the total order price
              double totalOrderPrice = calculateTotalPrice();

              // Create an order document in the 'orders' collection
              DocumentReference orderRef =
                  await FirebaseFirestore.instance.collection('orders').add({
                'userId': widget.userUid,
                'totalOrderPrice': totalOrderPrice,
                'finalPrice': finalPrice, // Add finalPrice
                'shippingFees': shippingFees, // Add shippingFees
                'status': 1, // Status for pending
                'timestamp': FieldValue.serverTimestamp(),
              });
              String orderId = orderRef.id;

              // Fetch user information
              DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userUid)
                  .get();

              if (userSnapshot.exists) {
                String username = userSnapshot['username'];
                String address = userSnapshot['address'];
                String phone = userSnapshot['phone'];

                // Iterate through selected items
                for (var item in widget.selectedItems) {
                  // Get product details from the cart item
                  String productId = item['productId'];
                  int cartQuantity = item['quantity'];
                  double itemDiscountedPrice = item['discountedPrice'];
                  String imageUrl = item['imageUrl'];
                  String productName = item['name'];
                  String sellerId = item['sellerId'];

                  // Fetch shopName based on sellerId
                  DocumentSnapshot sellerSnapshot = await FirebaseFirestore
                      .instance
                      .collection('sellers')
                      .doc(sellerId)
                      .get();

                  String shopName = '';

                  if (sellerSnapshot.exists) {
                    shopName = sellerSnapshot['shopName'];
                  }

                  // Calculate order details
                  double itemTotalPrice = itemDiscountedPrice * cartQuantity;

                  // Create an order document in the 'userOrders' subcollection
                  await orderRef.collection('userOrders').add({
                    'orderId': orderId,
                    'productId': productId,
                    'quantity': cartQuantity,
                    'itemTotalPrice': itemTotalPrice,
                    'imageUrl': imageUrl,
                    'productName': productName,
                    'sellerId': sellerId,
                    'userId': widget.userUid,
                    'status': 1, // Status for pending
                    'timestamp': FieldValue.serverTimestamp(),
                    'username': username,
                    'shopName': shopName, // Use the fetched shopName
                    'address': address,
                    'phone': phone,
                  });

                  // Remove item from the cart
                  await FirebaseFirestore.instance
                      .collection('carts')
                      .doc(item.id)
                      .delete();
                }

                // Clear selected items
                widget.selectedItems.clear();

                // Close the dialog
                Navigator.of(context).pop();

                // Navigate to the order confirmation screen with the order ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentGatewayScreen(
                      orderId: orderId,
                      userUid: widget.userUid,
                    ),
                  ),
                );
              } else {
                // Handle the case where the user document doesn't exist
                print('User document does not exist.');
              }
            } catch (e) {
              print('Error creating order: $e');
            }
          },
          child: Text('Pay'),
        ),
      ],
    );
  }
}
