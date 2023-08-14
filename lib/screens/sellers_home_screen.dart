import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:ecommerce/screens/seller_information.dart';
import 'package:ecommerce/sellerScreen/manage_product.dart';
import 'package:flutter/material.dart';

class SellerHomePage extends StatefulWidget {
  final String sellerId;

  const SellerHomePage({required this.sellerId});

  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  String _searchText = '';

  Widget _searchBar() {
    return Container(
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
          Icon(Icons.search),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                  print('Search Text: $_searchText');
                });
              },
              decoration: InputDecoration(
                hintText: 'Search product...',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSearchDialog() async {
    final searchController = TextEditingController(
        text: _searchText); // Initialize with current search text

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Product'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Enter product name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _searchText = searchController.text;
                  print('Search Text over here: $_searchText');
                });
              },
              child: const Text('Search'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _searchText = ''; // Clear search text
                });
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Homepage'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('sellers')
                  .doc(widget.sellerId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('Seller Not Found');
                }

                final sellerData = snapshot.data!.data()!;
                final shopName = sellerData['shopName'];
                final imageUrl =
                    sellerData['image_url'] ?? ''; // Fetch the imageUrl
                ImageProvider<Object>? avatarImage;

                if (imageUrl.isNotEmpty) {
                  avatarImage = NetworkImage(imageUrl);
                } else {
                  final defaultAvatarImage =
                      AssetImage('assets/images/default-avatar.png');
                  avatarImage = defaultAvatarImage;
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Align items horizontally at the center
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          avatarImage, // Display the fetched imageUrl
                    ),
                    SizedBox(
                        width:
                            16.0), // Add some spacing between CircleAvatar and Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SellerInformationPage(
                                  sellerId: widget.sellerId,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            shopName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // Add your chat logic here
                              },
                              icon: Icon(Icons.chat),
                              label: Text('Chat'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('sellersId', isEqualTo: widget.sellerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Text('No Products Available');
                  }

                  final products = snapshot.data!.docs;

                  final filteredProducts = products
                      .where((product) => product['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchText.toLowerCase()))
                      .toList();

                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final productData = filteredProducts[index].data();
                      final productId = filteredProducts[index].id;
                      final int maxQuantity = productData['quantity'] ?? 0;
                      final double price = productData['price'];
                      final double discount = productData['discount'] ?? 0.0;
                      final double discountedPrice =
                          (1 - discount / 100) * price;

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
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (discount > 0)
                                      Text(
                                        'RM${price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
