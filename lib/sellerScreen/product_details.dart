import 'package:flutter/material.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> productData;

  const ProductDetailsScreen({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the product details here
            // You can use Image.network, Text, etc. to show the details
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                productData['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Name',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['name'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Brand',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['brand'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Categoy',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['category'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Type',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['type'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['description'],
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Price',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['price'].toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Discount',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['discount'].toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Discounted Price',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['discountedPrice'].toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Part Number',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['partNumber'].toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Quantity',
                    style: TextStyle(fontSize: 24),
                  ),
                  Text(
                    productData['quantity'].toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.black,
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
