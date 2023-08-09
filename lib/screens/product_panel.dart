import 'package:flutter/material.dart';

class ProductPanelScreen extends StatelessWidget {
  final String query;

  const ProductPanelScreen({required this.query, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results for "$query"'),
      ),
      body: const Center(
        child: Text('Display search results here'),
      ),
    );
  }
}
