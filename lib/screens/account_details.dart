import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/sellerScreen/seller_home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/widget/button_widget.dart';
import 'package:ecommerce/widget/delivery_button.dart';
import 'package:ecommerce/userScreen/account_settings.dart';
import 'package:ecommerce/sellerScreen/become_seller.dart';
import 'package:ecommerce/userScreen/delivery_page.dart';
import 'package:ecommerce/screens/favorite_product.dart';
import 'package:ecommerce/screens/product_category.dart';
import 'package:ecommerce/userScreen/user_activity.dart';
import 'package:ecommerce/widget/data_fetcher.dart';
import 'dart:async';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  int toPayCount = 0;
  int toShipCount = 0;
  int toReceiveCount = 0;
  int toRateCount = 0;
  late Stream<DocumentSnapshot<Map<String, dynamic>>> isSellerStream;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _streamSubscription;

  bool _isCurrentUserSeller = false;
  String? _sellerId;

// To refresh the page
  Future<void> _refreshData() async {
    await _updateOrderCounts();
    _streamSubscription?.cancel();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      isSellerStream = FirebaseFirestore.instance
          .collection('sellers')
          .doc(currentUser.uid)
          .snapshots();

      _streamSubscription = isSellerStream.listen((snapshot) {});
    }
  }

  @override
  void initState() {
    super.initState();
    _updateOrderCounts();
    _refreshData();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      isSellerStream = FirebaseFirestore.instance
          .collection('sellers')
          .doc(currentUser.uid)
          .snapshots();
      _streamSubscription = isSellerStream.listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _isCurrentUserSeller = true;
            _sellerId = currentUser.uid;
          });
        } else {
          setState(() {
            _isCurrentUserSeller = false;
            _sellerId = null;
          });
        }
      });
    }
  }

  Future<Map<String, int>> fetchOrderCounts(String userId) async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    final orderCounts = {
      'toPay': 0,
      'toShip': 0,
      'toReceive': 0,
      'toRate': 0,
    };

    for (final orderDoc in ordersSnapshot.docs) {
      final orderId = orderDoc.id;
      final userOrdersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .collection('userOrders')
          .get();

      for (final doc in userOrdersSnapshot.docs) {
        final orderData = doc.data() as Map<String, dynamic>;
        final orderStatus = orderData['status'] as int?;
        final isRated = orderData['isRated'] ?? false;

        if (orderStatus != null) {
          if (orderStatus == 1) {
            orderCounts['toPay'] = (orderCounts['toPay'] ?? 0) + 1;
          } else if (orderStatus == 2) {
            orderCounts['toShip'] = (orderCounts['toShip'] ?? 0) + 1;
          } else if (orderStatus == 3) {
            orderCounts['toReceive'] = (orderCounts['toReceive'] ?? 0) + 1;
          }

          if (orderStatus == 4 && !isRated) {
            orderCounts['toRate'] = (orderCounts['toRate'] ?? 0) + 1;
          }
        }
      }
    }

    return orderCounts;
  }

  Future<void> _updateOrderCounts() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && mounted) {
      final orderCounts = await fetchOrderCounts(currentUser.uid);
      setState(() {
        toPayCount = orderCounts['toPay'] ?? 0;
        toShipCount = orderCounts['toShip'] ?? 0;
        toReceiveCount = orderCounts['toReceive'] ?? 0;
        toRateCount = orderCounts['toRate'] ?? 0;
      });
    }
  }

  void _navigateToDeliveryPage(BuildContext context, int tabIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryPage(initialTabIndex: tabIndex),
      ),
    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 75,
              child: FirestoreDataFetcher(
                userId: FirebaseAuth.instance.currentUser?.uid ?? '',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DeliveryButton(
                    icon: Icons.wallet,
                    label: 'To Pay',
                    count: toPayCount,
                    onPressed: () {
                      _navigateToDeliveryPage(context, 0);
                    },
                  ),
                ),
                Expanded(
                  child: DeliveryButton(
                    icon: Icons.card_giftcard,
                    label: 'To Ship',
                    count: toShipCount,
                    onPressed: () {
                      _navigateToDeliveryPage(context, 1);
                    },
                  ),
                ),
                Expanded(
                  child: DeliveryButton(
                    icon: Icons.fire_truck,
                    label: 'To Receive',
                    count: toReceiveCount,
                    onPressed: () {
                      _navigateToDeliveryPage(context, 2);
                    },
                  ),
                ),
                Expanded(
                  child: DeliveryButton(
                    icon: Icons.star,
                    label: 'Complete',
                    count: toRateCount,
                    onPressed: () {
                      _navigateToDeliveryPage(context, 3);
                    },
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Row(
              children: [
                ButtonWidget(
                  icon: _isCurrentUserSeller ? Icons.storefront : Icons.store,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: _isCurrentUserSeller ? 'Seller Home' : 'Become Seller',
                  onPressed: () {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      return;
                    }

                    if (_isCurrentUserSeller && _sellerId == currentUser.uid) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerHomeScreen(),
                        ),
                      );
                    } else if (_isCurrentUserSeller &&
                        _sellerId != currentUser.uid) {
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const SellerRegistrationScreen(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Row(
              children: [
                ButtonWidget(
                  icon: Icons.people,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'Account Setting',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Row(
              children: [
                ButtonWidget(
                  icon: Icons.category,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'Product Category',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductCategoryScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Row(
              children: [
                ButtonWidget(
                  icon: Icons.local_activity,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'User Activity',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserActivityScreen(userUid: currentUser!.uid),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Row(
              children: [
                ButtonWidget(
                  icon: Icons.favorite,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'Favorite Item',
                  onPressed: () {
                    if (currentUser == null) {
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteProductGridScreen(
                          userId: currentUser.uid,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.exit_to_app,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
