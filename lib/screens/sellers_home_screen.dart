import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/chatsScreen/chat_screen.dart';
import 'package:ecommerce/screens/product_details.dart';
import 'package:ecommerce/screens/seller_information.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellerHomePage extends StatefulWidget {
  final String sellerId;

  const SellerHomePage({super.key, required this.sellerId});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String _searchText = '';
  late Map<String, dynamic> _sellerInfo;
  late Map<String, dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _fetchSellerInfo(widget.sellerId);
    _fetchUserInfo();
  }

  Future<void> _fetchSellerInfo(String sellerId) async {
    final sellerSnapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(sellerId)
        .get();

    if (sellerSnapshot.exists) {
      setState(() {
        _sellerInfo = sellerSnapshot.data()!;
      });
    }
  }

  Future<void> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          _userInfo = userSnapshot.data()!;
        });
      }
    }
  }

  Widget _buildRatingStars(dynamic rating) {
    if (rating == null || rating is! num) {
      return const Text('N/A');
    }

    double ratingValue = rating.toDouble();
    if (ratingValue < 0 || ratingValue > 5) {
      return const Text('N/A');
    }

    int starCount = ratingValue.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        starCount,
        (index) => const Icon(
          Icons.star,
          color: Colors.yellow,
        ),
      ),
    );
  }

  Future<double> fetchSellerAverageRating(String sellerId) async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('sellerId', isEqualTo: sellerId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      return 0.0; // No reviews yet
    }

    double totalRating = 0;
    int validReviewCount = 0; // Count of valid reviews (non-null sellerRating)

    for (var reviewDoc in reviewsSnapshot.docs) {
      final reviewData = reviewDoc.data();
      final sellerRating = reviewData['sellerRating'] as num?;
      if (sellerRating != null) {
        totalRating += sellerRating.toDouble();
        validReviewCount++;
      }
    }

    if (validReviewCount == 0) {
      return 0.0; // No valid reviews with non-null sellerRating
    }

    double averageRating = totalRating / validReviewCount;
    return averageRating;
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
            decoration: const InputDecoration(hintText: 'Enter product name'),
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
        title: const Text('Seller Homepage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
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
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Text('Seller Not Found');
                }

                final sellerData = snapshot.data!.data()!;
                final shopName = sellerData['shopName'];
                final imageUrl =
                    sellerData['image_url'] ?? ''; // Fetch the imageUrl
                ImageProvider<Object>? avatarImage;

                if (imageUrl.isNotEmpty) {
                  avatarImage = NetworkImage(imageUrl);
                } else {
                  const defaultAvatarImage =
                      AssetImage('assets/images/default-avatar.png');
                  avatarImage = defaultAvatarImage;
                }
                final sellerRating = fetchSellerAverageRating(widget.sellerId);
                return Row(
                  mainAxisAlignment: MainAxisAlignment
                      .center, // Align items horizontally at the center
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          avatarImage, // Display the fetched imageUrl
                    ),
                    const SizedBox(
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        FutureBuilder<double>(
                          future: sellerRating,
                          builder: (context, ratingSnapshot) {
                            if (ratingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final sellerRatingValue =
                                ratingSnapshot.data ?? 0.0;

                            return Row(
                              children: [
                                _buildRatingStars(sellerRatingValue),
                              ],
                            );
                          },
                        ),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_sellerInfo.isEmpty || _userInfo.isEmpty) {
                                  return; // Don't proceed if information is not available
                                }

                                final currentUserUid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                final sellerId = widget.sellerId;

                                if (currentUserUid != null) {
                                  final chatId =
                                      currentUserUid.compareTo(sellerId) < 0
                                          ? '$currentUserUid-$sellerId'
                                          : '$sellerId-$currentUserUid';

                                  final sender = currentUserUid;
                                  final receiver = sellerId;

                                  // Check if the chat exists
                                  final chatSnapshot = await FirebaseFirestore
                                      .instance
                                      .collection('chats')
                                      .doc(chatId)
                                      .get();

                                  if (chatSnapshot.exists) {
                                    // Chat exists, navigate to the chat screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatScreen(chatId: chatId),
                                      ),
                                    );
                                  } else {
                                    // Chat doesn't exist, initiate the chat
                                    await FirebaseFirestore.instance
                                        .collection('chats')
                                        .doc(chatId)
                                        .set({
                                      'sender': sender,
                                      'receiver': receiver,
                                      'lastMessage': '',
                                      'timestamp': FieldValue.serverTimestamp(),
                                      'sellerShopName': _sellerInfo['shopName'],
                                      'sellerImageUrl':
                                          _sellerInfo['image_url'],
                                      'userUsername': _userInfo['username'],
                                      'userImageUrl': _userInfo['image_url'],
                                    });

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatScreen(chatId: chatId),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.chat),
                              label: const Text('Chat'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .where('sellersId', isEqualTo: widget.sellerId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No Products Available');
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
