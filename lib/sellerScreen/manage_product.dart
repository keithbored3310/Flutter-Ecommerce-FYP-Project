import 'package:ecommerce/sellerScreen/add_product.dart';
import 'package:ecommerce/sellerScreen/edit_product.dart';
import 'package:ecommerce/sellerScreen/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> products = [];
  bool _sortAscending = true;
  String? _getCurrentSellerId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          PopupMenuButton<int>(
            onSelected: (value) {
              if (value == 1) {
                setState(() {
                  _sortAscending = true;
                });
              } else if (value == 2) {
                setState(() {
                  _sortAscending = false;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 1,
                child: Text('Sort A-Z'),
              ),
              const PopupMenuItem<int>(
                value: 2,
                child: Text('Sort Z-A'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddTypePage when the add icon button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              ).then((_) {
                // Refresh the list of types when returning from the AddTypePage
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellersId', isEqualTo: _getCurrentSellerId())
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final products = snapshot.data!.docs;
            final currentSellerId =
                _getCurrentSellerId(); // Get the current seller's sellerId

            if (!_sortAscending) {
              products.sort((a, b) => b['name'].compareTo(a['name']));
            } else {
              products.sort((a, b) => a['name'].compareTo(b['name']));
            }

            if (products.isEmpty) {
              // Display a message when there are no products
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No products available.',
                      style: TextStyle(fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the AddProductScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProductScreen(),
                          ),
                        ).then((_) {
                          // Refresh the list of products when returning from the AddProductScreen
                          setState(() {});
                        });
                      },
                      child: Text('Add Product'),
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index].data();
                final productId = products[index].id;

                // Check if the current seller's sellerId matches the product's sellerId
                if (currentSellerId == product['sellersId']) {
                  return ProductGridItem(
                    productName: product['name'],
                    imageUrl: product['imageUrl'],
                    price: product['price'],
                    discount: product['discount'],
                    discountedPrice: product['discountedPrice'],
                    onTap: () {
                      _navigateToProductDetails(
                          product); // Pass the entire product details
                    },
                    onEdit: () {
                      _navigateToEditProductScreen(productId, product);
                    },
                    onDelete: () {
                      _deleteProduct(productId);
                    },
                  );
                } else {
                  // Product is not added by the current seller, so don't display it
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _navigateToProductDetails(Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productData: productData),
      ),
    );
  }

  // Method to navigate to the AddProductScreen
  // void _navigateToAddProductScreen() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => AddProductScreen(),
  //     ),
  //   );
  // }

  void _navigateToEditProductScreen(
      String productId, Map<String, dynamic> productData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(
          productId: productId,
          productData: productData,
        ),
      ),
    ).then((_) {
      // Refresh the list of products when returning from the EditProductScreen
      setState(() {});
    });
  }

  // Method to delete a product
  Future<void> _deleteProduct(String productId) async {
    try {
      // Show a confirmation dialog before deleting the product
      bool confirmDelete = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content:
                const Text('Are you sure you want to delete this product?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Don't delete
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Confirm delete
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );

      if (confirmDelete == true) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .delete();
        // Show a success message or handle deletion success
      }
    } catch (e) {
      // Handle any errors that may occur during deletion
      print('Error deleting product: $e');
      // Show an error message or handle the error appropriately
    }
  }
}

class ProductGridItem extends StatelessWidget {
  final String productName;
  final String imageUrl;
  final double price;
  final double discount;
  final double discountedPrice;
  final VoidCallback onTap; // Add imageUrl
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  ProductGridItem({
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.discountedPrice,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridTile(
        child: GestureDetector(
          onTap: onTap,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Text('No Image'),
                  ),
                ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          title: Text(productName),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (discount > 0)
                Text(
                  'RM ${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              Text(
                'RM ${discountedPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  color: discount > 0 ? Colors.red : null,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
