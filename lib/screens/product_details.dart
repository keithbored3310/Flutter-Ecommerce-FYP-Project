import 'package:ecommerce/chatsScreen/chat_screen.dart';
import 'package:ecommerce/screens/cart_screen.dart';
import 'package:ecommerce/screens/sellers_home_screen.dart';
import 'package:ecommerce/userScreen/view_all_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/widget/add_to_cart_dialog.dart';

class ProductDetailsUserScreen extends StatefulWidget {
  final Map<String, dynamic> productData;
  final int maxQuantity;
  final String productId;

  const ProductDetailsUserScreen({
    required this.productData,
    required this.maxQuantity,
    required this.productId,
    super.key,
  });

  @override
  State<ProductDetailsUserScreen> createState() =>
      _ProductDetailsUserScreenState();
}

class _ProductDetailsUserScreenState extends State<ProductDetailsUserScreen> {
  bool _isFavorite = false; // Track if the product is in favorites
  int _cartItemCount = 0;

  late Map<String, dynamic> _sellerInfo;
  late Map<String, dynamic> _userInfo;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _updateCartItemCount();

    _fetchSellerInfo(widget.productData['sellersId']);
    _fetchUserInfo();
  }

  void _showEnlargedImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateCartItemCount() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final cartsSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      setState(() {
        _cartItemCount = cartsSnapshot.docs.length; // Update cart item count
      });
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
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

  Future<double> fetchAverageRating(String productId) async {
    final reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) {
      return 0.0; // No reviews yet
    }

    double totalRating = 0;
    int validReviewCount = 0; // Count of valid reviews (non-null productRating)

    for (var reviewDoc in reviewsSnapshot.docs) {
      final reviewData = reviewDoc.data();
      final productRating = reviewData['productRating'] as num?;
      if (productRating != null) {
        totalRating += productRating.toDouble();
        validReviewCount++;
      }
    }

    if (validReviewCount == 0) {
      return 0.0; // No valid reviews with non-null productRating
    }

    double averageRating = totalRating / validReviewCount;
    return averageRating;
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

  Future<void> _checkIfFavorite() async {
    final userId = _getCurrentUserId();
    if (userId != null) {
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(widget.productId)
          .get();

      setState(() {
        _isFavorite = favoritesSnapshot.exists;
      });
    }
  }

  Widget _buildAddToCartButton(BuildContext context, int quantity) {
    final bool canAddToCart = quantity > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: canAddToCart
              ? () {
                  _showAddToCartDialog(context, widget.maxQuantity);
                }
              : null,
        ),
        Text('Add to Cart',
            style: TextStyle(color: canAddToCart ? Colors.black : Colors.grey)),
      ],
    );
  }

  Future<void> _toggleFavorite() async {
    final userId = _getCurrentUserId();
    if (userId != null) {
      final favoritesRef = FirebaseFirestore.instance
          .collection('favorites')
          .doc(userId)
          .collection('products')
          .doc(widget.productId);

      if (_isFavorite) {
        await favoritesRef.delete();
      } else {
        await favoritesRef.set({});
      }

      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to Favorites' : 'Removed from Favorites',
          ),
        ),
      );
    }
  }

  void _showAddToCartDialog(BuildContext context, int maxQuantity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Add to Cart'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: AddToCartDialog(
                maxQuantity: maxQuantity,
                productId: widget.productId,
                userId: _getCurrentUserId()!,
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _updateCartItemCount(); // Call _updateCartItemCount() after the dialog is dismissed
    });
  }

  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

  Widget _buildSellerInfoBox(BuildContext context) {
    final sellerId = widget.productData['sellersId'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerHomePage(sellerId: sellerId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('sellers')
                  .doc(sellerId)
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
                final imageUrl = sellerData['image_url'] ?? '';
                ImageProvider<Object>? avatarImage;

                if (imageUrl.isNotEmpty) {
                  avatarImage = NetworkImage(imageUrl);
                } else {
                  const defaultAvatarImage =
                      AssetImage('assets/images/default-avatar.png');
                  avatarImage = defaultAvatarImage;
                }

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarImage,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shopName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        FutureBuilder<double>(
                          future: fetchSellerAverageRating(sellerId),
                          builder: (context, ratingSnapshot) {
                            if (ratingSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }

                            final sellerRating = ratingSnapshot.data ?? 0.0;
                            return _buildRatingStars(sellerRating);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchProductReviewsStream() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: widget.productId)
        .where('status', isEqualTo: 4)
        .limit(10)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _viewAllReviews() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewAllReviewsPage(productId: widget.productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double price = widget.productData['price'];
    final double discountedPrice =
        widget.productData['discountedPrice'] ?? -1.0;
    final bool hasDiscount = discountedPrice >= 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (_cartItemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 10,
                      minHeight: 10,
                    ),
                    child: Text(
                      _cartItemCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () {
                _showEnlargedImage(context, widget.productData['imageUrl']);
              },
              child: Image.network(
                widget.productData['imageUrl'],
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.productData['name'],
                style: const TextStyle(fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                hasDiscount
                    ? 'RM${discountedPrice.toStringAsFixed(2)}'
                    : 'RM${price.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            if (hasDiscount)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'RM${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.productData['description'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            _buildSellerInfoBox(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Part Number',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    widget.productData['partNumber'],
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder<double>(
                    future: fetchAverageRating(widget.productId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      final averageRating = snapshot.data ?? 0.0;
                      return Row(
                        children: [
                          _buildRatingStars(averageRating),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildDetailItem('Brand', widget.productData['brand']),
                  _buildDetailItem('Category', widget.productData['category']),
                  _buildDetailItem('Type', widget.productData['type']),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _fetchProductReviewsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No reviews available.');
                }

                return NotificationListener(
                  onNotification: (notification) {
                    if (notification is OverscrollNotification &&
                        notification.overscroll < 0) {
                      return true;
                    }
                    return false;
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Product Reviews',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: _viewAllReviews,
                            child: const Text('View All Reviews'),
                          ),
                        ],
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final reviewData = snapshot.data!.docs[index].data();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(reviewData['imageUrl']),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(reviewData['username']),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (reviewData['reviewImageUrl'] != null &&
                                        reviewData['reviewImageUrl'].isNotEmpty)
                                      Image.network(
                                        reviewData['reviewImageUrl'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    if (reviewData['comment'] != null)
                                      Text(reviewData['comment']),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildRatingStars(
                                            reviewData['productRating']),
                                        Text(
                                          reviewData['timestamp']
                                              .toDate()
                                              .toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 92,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat),
                    onPressed: () async {
                      if (_sellerInfo.isEmpty || _userInfo.isEmpty) {
                        return;
                      }

                      final currentUserUid =
                          FirebaseAuth.instance.currentUser?.uid;
                      final sellerId = widget.productData['sellersId'];

                      if (currentUserUid != null) {
                        final chatId = currentUserUid.compareTo(sellerId) < 0
                            ? '$currentUserUid-$sellerId'
                            : '$sellerId-$currentUserUid';

                        final sender = currentUserUid;
                        final receiver = sellerId;
                        final chatSnapshot = await FirebaseFirestore.instance
                            .collection('chats')
                            .doc(chatId)
                            .get();

                        if (chatSnapshot.exists) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chatId),
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
                            'unreadMessage': 0,
                            'lastMessage': '',
                            'timestamp': FieldValue.serverTimestamp(),
                            'sellerShopName': _sellerInfo['shopName'],
                            'sellerImageUrl': _sellerInfo['image_url'],
                            'userUsername': _userInfo['username'],
                            'userImageUrl': _userInfo['image_url'],
                          });

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chatId),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const Text('Chat with Seller'),
                ],
              ),
              _buildAddToCartButton(context, widget.productData['quantity']),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : null,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                  Text(_isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
