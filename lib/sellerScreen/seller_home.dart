import 'package:ecommerce/adminScreen/courier_screen.dart';
import 'package:ecommerce/chatsScreen/seller_chat_list.dart';
import 'package:ecommerce/sellerScreen/manage_order.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/sellerScreen/edit_seller.dart';
import 'package:ecommerce/adminScreen/brand_screen.dart';
import 'package:ecommerce/adminScreen/category_screen.dart';
import 'package:ecommerce/adminScreen/type_screen.dart';
import 'package:ecommerce/sellerScreen/manage_product.dart';
import 'package:ecommerce/widget/button_widget.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({Key? key}) : super(key: key);

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  late User? _user; // Declare a User object
  String _sellerId = ''; // Initialize sellerId as an empty string

  @override
  void initState() {
    super.initState();
    // Fetch user and seller information
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      setState(() {
        _user = _auth.currentUser; // Get the current user
      });

      if (_user != null) {
        // Use the user's UID to fetch sellerId
        DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
            .collection('sellers')
            .doc(_user!.uid)
            .get();

        setState(() {
          _sellerId = sellerSnapshot.id;
          print('sellerId: $_sellerId');
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
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
                    // Set the desired height directly in ButtonWidget
                    icon: Icons.fire_truck,
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
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ), // Add spacing between the buttons
              Row(
                children: [
                  ButtonWidget(
                    // Set the desired height directly in ButtonWidget
                    icon: Icons.fire_truck,
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
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ), // Add spacing between the buttons
              Row(
                children: [
                  ButtonWidget(
                    // Set the desired height directly in ButtonWidget
                    icon: Icons.fire_truck,
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
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
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
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ), // Add spacing between the buttons
              Row(
                children: [
                  ButtonWidget(
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Add Brand',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BrandScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ), // Add spacing between the buttons
              Row(
                children: [
                  ButtonWidget(
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Add Category',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CategoryScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ), // Add spacing between the buttons
              Row(
                children: [
                  ButtonWidget(
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Add Type',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TypeScreen()),
                      );
                    },
                  ),
                ],
              ),
              const Divider(
                thickness: 2.0, // Set the line width
                color: Colors.black, // Set the line color
              ),
              Row(
                children: [
                  ButtonWidget(
                    icon: Icons.store,
                    trailingIcon: Icons.arrow_forward_ios,
                    label: 'Add Courier',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CourierScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
