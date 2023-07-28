import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecommerce/models/product.dart';
import 'package:ecommerce/sellerScreen/add_product.dart';

class ManageProduct extends StatefulWidget {
  const ManageProduct({Key? key}) : super(key: key);

  @override
  State<ManageProduct> createState() => _ManageProductState();
}

class _ManageProductState extends State<ManageProduct> {
  var _isLoading = true;
  String? _error;
  List<Product> _product = [];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _refreshProduct() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadProduct();
  }

  void _loadProduct() async {
    final url = Uri.https(
      'ecommerce-cb642-default-rtdb.firebaseio.com',
      'product-list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<Product> loadedProduct = [];

      for (final item in listData.entries) {
        // Create separate lists for each product
        List<Map<String, dynamic>> categoryDataList = [];
        List<Map<String, dynamic>> brandDataList = [];
        List<Map<String, dynamic>> typeDataList = [];

        categoryDataList.add(item.value['category']);
        brandDataList.add(item.value['brand']);
        typeDataList.add(item.value['type']);
        loadedProduct.add(
          Product(
            id: item.key,
            brand: brandDataList,
            category: categoryDataList,
            discount: double.parse(item.value['discount'].toString()),
            discountedPrice:
                double.parse(item.value['discountedPrice'].toString()),
            name: item.value['name'],
            partNumber: int.parse(item.value['partNumber'].toString()),
            price: double.parse(item.value['price'].toString()),
            quantity: int.parse(item.value['quantity'].toString()),
            type: typeDataList,
          ),
        );
      }
      setState(() {
        _product = loadedProduct;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
  }

  void _addProduct() async {
    final newItem = await Navigator.of(context).push<Product>(
      MaterialPageRoute(
        builder: (ctx) => AddProduct(refreshCallback: _refreshProduct),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _product.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Product'),
        actions: [
          IconButton(
            onPressed: _addProduct,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text(_error!),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  separatorBuilder: (context, index) => SizedBox(height: 16.0),
                  itemCount: _product.length,
                  itemBuilder: (ctx, index) {
                    final product = _product[index];
                    final categoryNames = product.category
                        .map((category) => category['name'])
                        .join(', ');
                    final brandNames =
                        product.brand.map((brand) => brand['brand']).join(', ');
                    final typeNames =
                        product.type.map((type) => type['type']).join(', ');

                    return GridTile(
                      child: Container(
                        color: Colors.grey[200],
                        child: Column(
                          children: [
                            Text('Name: ${product.name}'),
                            Text('Price: RM${product.price}'),
                            Text('Category: $categoryNames'),
                            Text('Brand: $brandNames'),
                            Text('Type: $typeNames'),
                            Text('Quantity: ${product.quantity}'),
                            Text('Discount: ${product.discount}'),
                            Text(
                                'Discounted Price: ${product.discountedPrice}'),
                            // Add other product details you want to display
                            // ...
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Add edit product functionality here
                                    // For example: _editProduct(product);
                                  },
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add delete product functionality here
                                    // For example: _deleteProduct(product);
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
