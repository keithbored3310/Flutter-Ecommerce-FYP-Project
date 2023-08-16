import 'package:ecommerce/screens/order_confirmation.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late String userUid;
  late Stream<QuerySnapshot> cartItemsStream;
  List<String> selectedItems = []; // List to store selected item IDs
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

    print('Product Snapshot Data: ${productSnapshot.data()}'); // Debugging log

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

  void proceedToCheckout(QuerySnapshot<Object?> snapshot) async {
    double totalOrderPrice = calculateTotalPrice(snapshot.docs);

    // Create order document in the orders collection
    DocumentReference orderRef =
        await FirebaseFirestore.instance.collection('orders').add({
      'userId': userUid,
      'totalOrderPrice': totalOrderPrice, // Added totalOrderPrice
      'status': 1, // Status for pending
      'timestamp': FieldValue.serverTimestamp(),
    });
    String orderId = orderRef.id;
    // Iterate through selected items
    for (var itemId in selectedItems) {
      DocumentSnapshot cartItemSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(itemId)
          .get();

      // Get product details from the cart item
      String productId = cartItemSnapshot['productId'];
      int cartQuantity = cartItemSnapshot['quantity'];
      double itemDiscountedPrice = cartItemSnapshot['discountedPrice'];
      String imageUrl = cartItemSnapshot['imageUrl'];
      String productName = cartItemSnapshot['name'];
      String sellerId = cartItemSnapshot['sellerId'];

      // Calculate order details
      double itemTotalPrice = itemDiscountedPrice * cartQuantity;

      // Create order document in the userOrders subcollection
      await orderRef.collection('userOrders').add({
        'orderId': orderId,
        'productId': productId,
        'quantity': cartQuantity,
        'itemTotalPrice': itemTotalPrice,
        'imageUrl': imageUrl,
        'productName': productName,
        'sellerId': sellerId,
        'userId': userUid,
        'status': 1, // Status for pending
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Remove item from cart
      await FirebaseFirestore.instance.collection('carts').doc(itemId).delete();
    }

    // Clear selected items
    setState(() {
      selectedItems.clear();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderConfirmationScreen(
          orderId: orderRef.id,
          userUid: userUid,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartItemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No items in the cart.'),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsUserScreen(
                                productId: productId,
                                productData:
                                    productData, // Replace with actual product data from Firestore
                                maxQuantity:
                                    maxQuantity, // Replace with actual max quantity from Firestore
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
                            SizedBox(width: 10),
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
                                Spacer(), // Add spacer for alignment
                                IconButton(
                                  icon: Icon(Icons.remove_shopping_cart),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('carts')
                                        .doc(itemId)
                                        .delete();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text('Quantity: '),
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
                            Text('Select All'),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Total Price:',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              'RM ${calculateTotalPrice(snapshot.data!.docs).toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: selectedItems.isNotEmpty
                              ? () => proceedToCheckout(snapshot.data!)
                              : null,
                          icon: Icon(Icons.shopping_cart),
                          label: Text('Checkout'),
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

  QuantityAdjustment({
    required this.initialQuantity,
    required this.maxQuantity,
    required this.onQuantityChanged,
  });

  @override
  _QuantityAdjustmentState createState() => _QuantityAdjustmentState();
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
          icon: Icon(Icons.remove),
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
          icon: Icon(Icons.add),
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
