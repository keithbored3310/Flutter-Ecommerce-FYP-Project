import 'package:ecommerce/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final QuerySnapshot<Map<String, dynamic>> productsSnapshot =
        await FirebaseFirestore.instance
            .collection('products')
            .limit(3) // Limit the number of fetched products to 3
            .get();

    List<Map<String, dynamic>> products = [];

    productsSnapshot.docs.forEach((productDoc) {
      Map<String, dynamic> productData = productDoc.data();
      productData['productId'] = productDoc.id;
      products.add(productData);
    });

    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome to the Spare Parts Application',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching data'),
                  );
                } else if (!snapshot.hasData ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No products available'),
                  );
                } else {
                  List<Map<String, dynamic>> products = snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final imageUrl = products[index]['imageUrl'];
                      final productName = products[index]['name'];

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsUserScreen(
                                    productData: products[index],
                                    maxQuantity: products[index]['quantity'],
                                    productId: products[index]['productId'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 200.0,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    imageUrl,
                                    height: 150.0,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Text(
                                    productName,
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
