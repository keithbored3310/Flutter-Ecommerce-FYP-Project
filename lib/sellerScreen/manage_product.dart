import 'package:ecommerce/sellerScreen/add_product.dart';
import 'package:ecommerce/sellerScreen/edit_product.dart';
import 'package:ecommerce/sellerScreen/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/widget/filter_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String _searchText = '';
  List<Map<String, dynamic>> products = [];
  FilterOptions _filterOptions = FilterOptions();
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

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      getFilteredAndSortedProducts(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> products) {
    // Apply sorting based on filter options
    if (_filterOptions.sortAscending) {
      products.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_filterOptions.sortDescending) {
      products.sort((a, b) => b['name'].compareTo(a['name']));
    }

    // Apply sorting based on filter options for price
    if (_filterOptions.sortPriceAscending) {
      products
          .sort((a, b) => a['discountedPrice'].compareTo(b['discountedPrice']));
    } else if (_filterOptions.sortPriceDescending) {
      products
          .sort((a, b) => b['discountedPrice'].compareTo(a['discountedPrice']));
    }

    // Filter based on price range
    return products
        .where((product) =>
            (_filterOptions.minPrice == null ||
                product['discountedPrice'] >= _filterOptions.minPrice!) &&
            (_filterOptions.maxPrice == null ||
                product['discountedPrice'] <= _filterOptions.maxPrice!))
        .toList();
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController(text: _searchText);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Product'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(hintText: 'Enter product name'),
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
                  // print('Search Text over here: $_searchText');
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
                  _searchText = '';
                  _filterOptions = FilterOptions();
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
            icon: const Icon(Icons.search),
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
                      });
                    },
                    onClear: () {
                      refreshProductList(FilterOptions(), null, null, null);
                    },
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddProductScreen(),
                ),
              ).then((_) {
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

              // print('Search Text in this place: $_searchText');
              // Filter based on product name
              final filteredProducts = products
                  .where((product) => product['name']
                      .toString()
                      .toLowerCase()
                      .contains(_searchText.toLowerCase()))
                  .toList();
              final currentSellerId = _getCurrentSellerId();

              final sortedAndFilteredProducts =
                  getFilteredAndSortedProducts(filteredProducts);

              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'No products available.',
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        child: const Text('Add Product'),
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
                itemCount: sortedAndFilteredProducts.length,
                itemBuilder: (context, index) {
                  final productData = sortedAndFilteredProducts[index].data();
                  final productId = sortedAndFilteredProducts[index].id;
                  final double price = productData['price'];
                  final double discount = productData['discount'] ?? 0.0;
                  final double discountedPrice = (1 - discount / 100) * price;

                  if (currentSellerId == productData['sellersId']) {
                    return ProductGridItem(
                      productName: productData['name'],
                      imageUrl: productData['imageUrl'],
                      price: price,
                      discount: discount,
                      discountedPrice: discountedPrice,
                      onTap: () {
                        _navigateToProductDetails(productData);
                      },
                      onEdit: () {
                        _navigateToEditProductScreen(productId, productData);
                      },
                      onDelete: () {
                        _deleteProduct(productId);
                      },
                    );
                  } else {
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
      setState(() {});
    });
  }

  // Method to delete a product
  Future<void> _deleteProduct(String productId) async {
    try {
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
                  Navigator.of(context).pop(false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
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
      }
    } catch (e) {
      // print('Error deleting product: $e');
    }
  }
}

class ProductGridItem extends StatelessWidget {
  final String productName;
  final String imageUrl;
  final double price;
  final double discount;
  final double discountedPrice;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductGridItem({
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.discount,
    required this.discountedPrice,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    super.key,
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
