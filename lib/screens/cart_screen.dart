import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _currentUserId;
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  void _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: _currentUserId != null
          ? Column(
              children: [
                Expanded(
                  child: _buildCartItemsList(),
                ),
                _buildBottomBar(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildCartItemsList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching cart items'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Center(
                child: Text(
                  'Oops, Your shopping cart is empty',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Browse our awesome products now!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Navigate back to previous page
                },
                child: const Text('Go Shopping Now'),
              ),
            ],
          );
        } else {
          final cartItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItemDoc = cartItems[index];
              final cartItemData = cartItemDoc.data();
              final String productId = cartItemData['productId'];

              // Pass cartItemDoc to display the cart item details
              return _buildCartItemWidget(cartItemDoc);
            },
          );
        }
      },
    );
  }

  Widget _buildCartItemWidget(
    QueryDocumentSnapshot<Map<String, dynamic>> cartItemDoc,
  ) {
    final cartId = cartItemDoc.id;
    final cartItemData = cartItemDoc.data();
    final String productId = cartItemData['productId'];
    int currentQuantity = cartItemData['quantity'];
    final String productName = cartItemData['name'];
    final String imageUrl = cartItemData['imageUrl'];
    double discountedPrice = cartItemData['discountedPrice'];

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error fetching product details'));
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Product not found'));
        } else {
          final productData = snapshot.data!.data();
          final int maxQuantity = productData!['quantity'];

          return Column(
            children: [
              ListTile(
                leading: Checkbox(
                  value: _selectAll,
                  onChanged: (newValue) {
                    setState(() {
                      _selectAll = newValue!;
                    });
                  },
                ),
                title: Row(
                  children: [
                    Image.network(imageUrl, width: 50, height: 50),
                    const SizedBox(
                        width: 10), // Add some spacing between image and text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'RM ${discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QuantityDisplay(
                      quantity: currentQuantity,
                      maxQuantity: maxQuantity,
                      onUpdate: (newQuantity) {
                        _updateCartItemQuantity(
                            cartId, newQuantity, maxQuantity, currentQuantity);
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _removeCartItem(cartId);
                    },
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: const Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: (newValue) {
                  setState(() {
                    _selectAll = newValue!;
                  });
                },
              ),
              const Text('Select All'),
            ],
          ),
          Column(
            children: [
              const Text(
                  'Total Price: \$123.45'), // Calculate total price based on selected items
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // Implement checkout logic
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => CheckoutScreen(),
                  //   ),
                  // );
                },
                child: const Text('Checkout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _removeCartItem(String cartItemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(cartItemId)
          .delete();
    } catch (e) {
      print('Error removing item: $e');
      // Handle any errors that may occur
    }
  }

  void _updateCartItemQuantity(String cartItemId, int newQuantity,
      int maxQuantity, int currentQuantity) async {
    try {
      // Fetch the product details to get the actual maxQuantity
      final cartItemSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(cartItemId)
          .get();
      final productId = cartItemSnapshot['productId'];

      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      final productData = productSnapshot.data();

      final int actualMaxQuantity = productData!['quantity'];

      if (newQuantity > actualMaxQuantity) {
        newQuantity = actualMaxQuantity;
        // Display a snackbar here to inform the user
        // Snackbar logic goes here...
      }

      if (newQuantity < 1) {
        // Remove the cart item from the collection
        _removeCartItem(cartItemId);
      } else {
        // Update the quantity of the cart item
        await FirebaseFirestore.instance
            .collection('carts')
            .doc(cartItemId)
            .update({
          'quantity': newQuantity,
        });
      }
    } catch (e) {
      print('Error updating quantity: $e');
      // Handle any errors that may occur
    }
  }
}

class QuantityDisplay extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onUpdate;

  const QuantityDisplay({
    required this.quantity,
    required this.maxQuantity,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (quantity > 1) {
              onUpdate(quantity - 1);
            }
          },
        ),
        Text('$quantity'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (quantity < maxQuantity) {
              onUpdate(quantity + 1);
            }
          },
        ),
      ],
    );
  }
}
