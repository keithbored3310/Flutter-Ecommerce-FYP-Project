import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSalesScreen extends StatefulWidget {
  final String sellerId;

  const ManageSalesScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  _ManageSalesScreenState createState() => _ManageSalesScreenState();
}

class _ManageSalesScreenState extends State<ManageSalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Sales'),
      ),
      body: FutureBuilder<List<ProductSalesEntry>>(
        future: fetchProductSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No sales data available.');
          } else {
            final totalEarnings = snapshot.data!
                .map((productSales) => productSales.itemTotalPrice)
                .fold<double>(0, (a, b) => a + b);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '\$$totalEarnings',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final productSales = snapshot.data![index];
                    return ListTile(
                      title: Text('Product Name: ${productSales.productName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quantity: ${productSales.quantity}'),
                          Text(
                            'Item Total Price: \$${productSales.itemTotalPrice.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    );
                  },
                )),
              ],
            );
          }
        },
      ),
    );
  }

  Future<List<ProductSalesEntry>> fetchProductSales() async {
    try {
      final sellerSalesDocReference = FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerId)
          .collection('sales')
          .doc('${DateTime.now().year}-${DateTime.now().month}');

      final sellerSalesData = await sellerSalesDocReference.get();

      if (sellerSalesData.exists && sellerSalesData['productSales'] != null) {
        final productSalesArray =
            sellerSalesData['productSales'] as List<dynamic>;
        final productSales = <ProductSalesEntry>[];

        for (final productSale in productSalesArray) {
          final productId = productSale['productId'];
          final productName = productSale['productName'];
          final quantity = productSale['quantity'];
          final itemTotalPrice = productSale['itemTotalPrice'];

          productSales.add(ProductSalesEntry(
            productId: productId,
            productName: productName,
            quantity: quantity,
            itemTotalPrice: itemTotalPrice,
          ));
        }

        return productSales;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching product sales: $e');
      return [];
    }
  }
}

class ProductSalesEntry {
  final String productId;
  final String productName;
  final int quantity;
  final double itemTotalPrice;

  ProductSalesEntry({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.itemTotalPrice,
  });
}
