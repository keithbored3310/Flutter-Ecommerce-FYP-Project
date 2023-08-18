import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddToCartDialog extends StatefulWidget {
  final int maxQuantity;
  final String productId; // Add productId parameter
  final String userId;

  const AddToCartDialog({
    super.key,
    required this.maxQuantity,
    required this.productId, // Add productId parameter
    required this.userId,
  });

  @override
  State<AddToCartDialog> createState() => _AddToCartDialogState();
}

class _AddToCartDialogState extends State<AddToCartDialog> {
  int quantity = 1;
  bool isAddingToCart = false;

  late FocusNode _quantityFocusNode;
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityFocusNode = FocusNode();
    _quantityController = TextEditingController(text: quantity.toString());
    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _quantityFocusNode.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    int newQuantity = int.tryParse(_quantityController.text) ?? 1;
    newQuantity = newQuantity.clamp(1, widget.maxQuantity);
    setState(() {
      quantity = newQuantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adjust Quantity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select quantity:'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (quantity > 1) {
                      quantity--;
                    }
                    _quantityController.text = quantity.toString();
                  });
                },
              ),
              SizedBox(
                width: 50, // Adjust the width to your preference
                child: TextFormField(
                  focusNode: _quantityFocusNode,
                  controller: _quantityController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (quantity < widget.maxQuantity) {
                      quantity++;
                    }
                    _quantityController.text = quantity.toString();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: isAddingToCart
              ? null
              : () async {
                  setState(() {
                    isAddingToCart = true; // Start adding to cart
                  });

                  // Use the passed productId directly
                  String productId = widget.productId;

                  // Add the logic to handle adding to cart here
                  // You can use the 'quantity', 'productId', 'widget.userId', and other necessary data
                  await _addToCart(quantity, productId, widget.userId);

                  // Show snackbar for successful add to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to Cart'),
                    ),
                  );

                  setState(() {
                    isAddingToCart = false; // Finished adding to cart
                  });

                  Navigator.of(context).pop(); // Close the dialog
                },
          child: isAddingToCart
              ? const CircularProgressIndicator() // Show progress indicator
              : const Text('Add to Cart'),
        ),
      ],
    );
  }

  Future<void> _addToCart(int quantity, String productId, String userId) async {
    try {
      // Query the 'products' collection to get the seller's ID
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (!productSnapshot.exists) {
        // Handle the case where the product doesn't exist
        print('Product not found');
        return;
      }

      final sellerId = productSnapshot.get('sellersId') as String;
      final name = productSnapshot.get('name') as String;
      final imageUrl = productSnapshot.get('imageUrl') as String;
      final discountedPrice = productSnapshot.get('discountedPrice') as double;

      // Query the 'carts' collection to get existing cart item, if any
      final existingCartItemQuery = await FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: productId)
          .get();

      int totalQuantity = quantity; // Initialize with selected quantity
      if (existingCartItemQuery.docs.isNotEmpty) {
        // If item already exists, update the quantity
        final existingCartItem = existingCartItemQuery.docs.first;
        final existingQuantity = existingCartItem['quantity'] as int;
        totalQuantity += existingQuantity; // Add existing quantity to total
      }

      if (totalQuantity > widget.maxQuantity) {
        // Display a snackbar to inform the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Total quantity exceeds maximum allowed.'),
          ),
        );
        return; // Do not proceed further
      }

      if (existingCartItemQuery.docs.isNotEmpty) {
        // If item already exists, update the quantity
        final existingCartItem = existingCartItemQuery.docs.first;
        final existingQuantity = existingCartItem['quantity'];
        await existingCartItem.reference
            .update({'quantity': existingQuantity + quantity});
      } else {
        // If item doesn't exist, add a new document
        await FirebaseFirestore.instance.collection('carts').add({
          'userId': userId,
          'sellerId': sellerId, // Save the seller's ID
          'productId': productId,
          'quantity': quantity,
          'name': name,
          'imageUrl': imageUrl,
          'discountedPrice': discountedPrice,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error adding to cart: $e');
      // Handle any errors that may occur
    }
  }
}
