import 'package:ecommerce/screens/product_grid_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<String>> fetchCategories() async {
  try {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs
        .map((doc) =>
            (doc.data() as Map<String, dynamic>)['category'] as String? ?? '')
        .toList();
  } catch (e) {
    print('Error fetching categories: $e');
    return [];
  }
}

class ProductCategoryScreen extends StatelessWidget {
  const ProductCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Category')),
      body: FutureBuilder<List<String>>(
        future: fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching categories'));
          } else {
            final categories = snapshot.data ?? [];
            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductGridScreen(category: category),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      thickness: 2.0, // Set the line width
                      color: Colors.black, // Set the line color
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
