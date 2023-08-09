import 'package:ecommerce/screens/cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widget/add_to_cart_dialog.dart';

class ProductDetailsUserScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final int maxQuantity;
  final String productId;

  const ProductDetailsUserScreen({
    required this.productData,
    required this.maxQuantity,
    required this.productId,
    Key? key,
  }) : super(key: key);

  @override
  _ProductDetailsUserScreenState createState() =>
      _ProductDetailsUserScreenState();
}

class _ProductDetailsUserScreenState extends State<ProductDetailsUserScreen> {
  bool _isFavorite = false; // Track if the product is in favorites

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildRatingStars(dynamic rating) {
    if (rating == null || rating is! num) {
      return const Text('N/A');
    }

    double ratingValue = rating.toDouble();
    if (ratingValue < 0 || ratingValue > 5) {
      return const Text('N/A');
    }

    int starCount = ratingValue.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        starCount,
        (index) => const Icon(
          Icons.star,
          color: Colors.yellow,
        ),
      ),
    );
  }

  Future<void> _checkIfFavorite() async {
    final userId = _getCurrentUserId();
    if (userId != null) {
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(widget.productId)
          .get();

      setState(() {
        _isFavorite = favoritesSnapshot.exists;
      });
    }
  }

  Widget _buildAddToCartButton(BuildContext context, int quantity) {
    final bool canAddToCart = quantity > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: canAddToCart
              ? () {
                  _showAddToCartDialog(context, widget.maxQuantity);
                }
              : null,
        ),
        Text('Add to Cart',
            style: TextStyle(color: canAddToCart ? Colors.black : Colors.grey)),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    final userId = _getCurrentUserId();
    if (userId != null) {
      final favoritesRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(widget.productId);

      if (_isFavorite) {
        await favoritesRef.delete();
      } else {
        await favoritesRef.set({});
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
          ),
        ),
      );
    }
  }

  void _showAddToCartDialog(BuildContext context, int maxQuantity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddToCartDialog(
          maxQuantity: maxQuantity,
          productId: widget.productId,
          userId: _getCurrentUserId()!,
        );
      },
    );
  }

  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final double price = widget.productData['price'];
    final double discountedPrice =
        widget.productData['discountedPrice'] ?? -1.0;
    final bool hasDiscount = discountedPrice >= 0;
    print('Product ID: ${widget.productId}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.productData['imageUrl'],
              height: 300,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.productData['name'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                hasDiscount
                    ? 'RM${discountedPrice.toStringAsFixed(2)}'
                    : 'RM${price.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (hasDiscount)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'RM${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.productData['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Part Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.productData['partNumber'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  _buildRatingStars(widget.productData['rating']),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDetailItem('Brand', widget.productData['brand']),
                  _buildDetailItem('Category', widget.productData['category']),
                  _buildDetailItem('Type', widget.productData['type']),
                ],
              ),
            ),
            // Add more product details as needed
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 92, // Adjust the height as needed
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () {
                      // Add your logic for chatting with the seller here
                    },
                  ),
                  const Text('Chat with Seller'),
                ],
              ),
              _buildAddToCartButton(context, widget.productData['quantity']),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  Text(_isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
