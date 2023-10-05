import 'package:ecommerce/sellerScreen/products_reviews.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductListPage extends StatelessWidget {
  final String sellerId;

  const ProductListPage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('sellersId', isEqualTo: sellerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final products = snapshot.data?.docs;

          if (products == null || products.isEmpty) {
            return const Center(
              child: Text('No products found.'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productId = product.id;
              final productName = product['name'];

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductsReviewPage(productId: productId),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(productName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
