//Build a screen to display product category
import 'package:flutter/material.dart';

class ProductCategoryScreen extends StatelessWidget {
  const ProductCategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Category')),
      body: const Center(
        child: Text('Go back!'),
      ),
    );
  }
}
