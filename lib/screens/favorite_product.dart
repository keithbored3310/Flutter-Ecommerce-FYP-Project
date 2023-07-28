//build a screen to display favorite product
import 'package:flutter/material.dart';

class FavoriteProductScreen extends StatelessWidget {
  const FavoriteProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Product')),
      body: const Center(
        child: Text('Go back!'),
      ),
    );
  }
}
