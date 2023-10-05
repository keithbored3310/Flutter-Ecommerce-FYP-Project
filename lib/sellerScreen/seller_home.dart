import 'package:ecommerce/chatsScreen/seller_chat_list.dart';
import 'package:ecommerce/sellerScreen/manage_order.dart';
import 'package:ecommerce/sellerScreen/manage_sales.dart';
import 'package:ecommerce/sellerScreen/product_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/sellerScreen/edit_seller.dart';
import 'package:ecommerce/sellerScreen/manage_product.dart';
import 'package:ecommerce/widget/button_widget.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({Key? key}) : super(key: key);

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late User? _user;
  String _sellerId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      setState(() {
        _user = _auth.currentUser;
      });

      if (_user != null) {
        DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(_user!.uid)
            .get();

        setState(() {
          _sellerId = sellerSnapshot.id;
          // print('sellerId: $_sellerId');
        });
      }
    } catch (e) {
      // print('Error fetching user info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Home'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ButtonWidget(
                    icon: Icons.shopping_bag,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Manage Order',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManageOrderPage(sellerId: _sellerId),
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
                    icon: Icons.people,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Manage Sellers Information',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditSellerScreen(sellerId: _sellerId),
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
                    icon: Icons.chat,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Manage Chats',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SellerChatListScreen(sellerId: _sellerId),
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
                    icon: Icons.bar_chart,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Manage Sales',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ManageSalesScreen(sellerId: _sellerId),
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
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Manage Product',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProductListScreen()),
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
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'View Reviews',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProductListPage(sellerId: _sellerId)),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 2.0,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
