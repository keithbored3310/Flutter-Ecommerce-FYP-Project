import 'package:ecommerce/sellerScreen/add_product.dart';
import 'package:ecommerce/sellerScreen/edit_product.dart';
import 'package:ecommerce/sellerScreen/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/widget/filter_dialog.dart';

// Make sure to adjust the import path as needed

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String _searchText = '';
  List<Map<String, dynamic>> products = [];
  FilterOptions _filterOptions = FilterOptions();
  bool _sortAscending = true;
  String? _selectedBrand;
  String? _selectedCategory;
  String? _selectedType;
  String? _getCurrentSellerId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: kToolbarHeight - 8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  print('Search Text: $_searchText');
                });
              },
              decoration: InputDecoration(
                hintText: 'Search product...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> refreshProductList(
      FilterOptions filterOptions,
      String? selectedBrand,
      String? selectedCategory,
      String? selectedType) async {
    setState(() {
      _filterOptions = filterOptions;
      _selectedBrand = selectedBrand;
      _selectedCategory = selectedCategory;
      _selectedType = selectedType;
    });
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController(
        text: _searchText); // Initialize with current search text

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Product'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Enter product name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _searchText = searchController.text;
                  print('Search Text over here: $_searchText');
                  // Clear filter options and selected values
                  _filterOptions = FilterOptions();
                  _selectedBrand = null;
                  _selectedCategory = null;
                  _selectedType = null;
                });
              },
              child: const Text('Search'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _searchText = ''; // Clear search text
                  _filterOptions = FilterOptions(); // Clear filter options
                  _selectedBrand = null;
                  _selectedCategory = null;
                  _selectedType = null;
                });
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searchText.isEmpty ? const Text('Product List') : null,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FilterDialog(
                    initialFilterOptions: _filterOptions,
                    selectedBrand: _selectedBrand,
                    selectedCategory: _selectedCategory,
                    selectedType: _selectedType,
                    onApply: (options, newBrand, newCategory, newType) {
                      // Modify this line
                      setState(() {
                        _filterOptions = options;
                        _selectedBrand = newBrand;
                        _selectedCategory = newCategory;
                        _selectedType = newType;
                        print('New Brand: $_selectedBrand');
                      });
                    },
                    onClear: () {
                      // Clear filters and refresh product list
                      refreshProductList(FilterOptions(), null, null,
                          null); // Pass initialFilterOptions and null for selectedBrand
                    },
                  );
                },
              );
            },
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
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: () async {},
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('products')
              .where('sellersId', isEqualTo: _getCurrentSellerId())
              .where('brand', isEqualTo: _selectedBrand)
              .where('category', isEqualTo: _selectedCategory)
              .where('type', isEqualTo: _selectedType)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<QueryDocumentSnapshot<Map<String, dynamic>>> products =
                  snapshot.data!.docs;

              print('Search Text in this place: $_searchText');
              // Filter based on product name
              final filteredProducts = products
                  .where((product) => product['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchText.toLowerCase()))
                  .toList();
              final currentSellerId =
                  _getCurrentSellerId(); // Get the current seller's sellerId

              // Apply sorting based on filter options
              if (_filterOptions.sortAscending) {
                products.sort((a, b) => a['name'].compareTo(b['name']));
              } else if (_filterOptions.sortDescending) {
                products.sort((a, b) => b['name'].compareTo(a['name']));
              }

              // Apply sorting based on filter options for price
              if (_filterOptions.sortPriceAscending) {
                products.sort((a, b) =>
                    a['discountedPrice'].compareTo(b['discountedPrice']));
              } else if (_filterOptions.sortPriceDescending) {
                products.sort((a, b) =>
                    b['discountedPrice'].compareTo(a['discountedPrice']));
              }

              // Filter based on price range
              products = products
                  .where((product) =>
                      (_filterOptions.minPrice == null ||
                          product['discountedPrice'] >=
                              _filterOptions.minPrice!) &&
                      (_filterOptions.maxPrice == null ||
                          product['discountedPrice'] <=
                              _filterOptions.maxPrice!))
                  .toList();

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
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final productData = filteredProducts[index].data();
                  final productId = filteredProducts[index].id;
                  final int maxQuantity = productData['quantity'] ?? 0;
                  final double price = productData['price'];
                  final double discount = productData['discount'] ?? 0.0;
                  final double discountedPrice = (1 - discount / 100) * price;

                  // Check if the current seller's sellerId matches the product's sellerId
                  if (currentSellerId == productData['sellersId']) {
                    return ProductGridItem(
                      productName: productData['name'],
                      imageUrl: productData['imageUrl'],
                      price: price,
                      discount: discount,
                      discountedPrice: discountedPrice,
                      onTap: () {
                        _navigateToProductDetails(
                            productData); // Pass the entire product details
                      },
                      onEdit: () {
                        _navigateToEditProductScreen(productId, productData);
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
