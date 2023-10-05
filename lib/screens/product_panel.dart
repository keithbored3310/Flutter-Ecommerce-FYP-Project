import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:ecommerce/screens/search_screen.dart';
import 'package:ecommerce/widget/filter_dialog.dart';

class ProductPanelScreen extends StatefulWidget {
  final String query;

  const ProductPanelScreen({required this.query, super.key});

  @override
  State<ProductPanelScreen> createState() => _ProductPanelScreenState();
}

class _ProductPanelScreenState extends State<ProductPanelScreen> {
  FilterOptions _filterOptions = FilterOptions();
  String? _selectedBrand;
  String? _selectedCategory;
  String? _selectedType;

  List<QueryDocumentSnapshot<Map<String, dynamic>>>
      getFilteredAndSortedProducts(
          List<QueryDocumentSnapshot<Map<String, dynamic>>> products) {
    // Apply sorting based on filter options (case-insensitive)
    if (_filterOptions.sortAscending) {
      products.sort(
          (a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
    } else if (_filterOptions.sortDescending) {
      products.sort(
          (a, b) => b['name'].toLowerCase().compareTo(a['name'].toLowerCase()));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(initialQuery: widget.query),
              ),
            );
          },
          child: Container(
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
                const Icon(Icons.search),
                const SizedBox(width: 8),
                Text(widget.query),
              ],
            ),
          ),
        ),
        actions: [
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
                      setState(() {
                        _filterOptions = options;
                        _selectedBrand = newBrand;
                        _selectedCategory = newCategory;
                        _selectedType = newType;
                      });
                    },
                    onClear: () {
                      setState(() {
                        _filterOptions = FilterOptions();
                        _selectedBrand = null;
                        _selectedCategory = null;
                        _selectedType = null;
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('brand', isEqualTo: _selectedBrand)
            .where('category', isEqualTo: _selectedCategory)
            .where('type', isEqualTo: _selectedType)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching products'));
          } else {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> products =
                snapshot.data!.docs;

            final filteredProducts = products
                .where((product) => product['name']
                    .toString()
                    .toLowerCase()
                    .contains(widget.query.toLowerCase()))
                .toList();
            final sortedAndFilteredProducts =
                getFilteredAndSortedProducts(filteredProducts);

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
                final int maxQuantity = productData['quantity'] ?? 0;
                final double price = productData['price'];
                final double discount = productData['discount'] ?? 0.0;
                final double discountedPrice = (1 - discount / 100) * price;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsUserScreen(
                          productData: productData,
                          maxQuantity: maxQuantity,
                          productId: productId,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Image.network(
                          productData['imageUrl'],
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            productData['name'].length > 20
                                ? '${productData['name'].substring(0, 20)}...'
                                : productData['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (discount > 0)
                                Text(
                                  'RM${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                'RM${discountedPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
