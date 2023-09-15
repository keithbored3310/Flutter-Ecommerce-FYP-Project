import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/chatsScreen/user_chat_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce/screens/account_details.dart';
import 'package:ecommerce/screens/homepage.dart';
import 'package:ecommerce/screens/cart_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});
  static int chatStatusCount = 0;
  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  int _cartItemCount = 0;
  int _chatStatusCount = 0;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _cartItemsSubscription;

  @override
  void initState() {
    super.initState();
    _listenToCartItems(); // Start listening to cart item changes
    _listenToChatStatus();
  }

  void _listenToCartItems() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _cartItemsSubscription = FirebaseFirestore.instance
          .collection('carts')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _cartItemCount = snapshot.docs.length; // Update cart item count
        });
      });
    }
  }

  void _listenToChatStatus() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('chats')
          .where('sender', isEqualTo: currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        setState(() {
          _chatStatusCount = snapshot.docs.length; // Update chat status count
        });
      });
    }
  }

  static void updateChatStatusCountFromUserChatList(
      BuildContext context, int count) {
    final _TabsScreenState? state =
        context.findAncestorStateOfType<_TabsScreenState>();
    if (state != null) {
      state.updateChatStatusCount(count);
    }
  }

  void updateChatStatusCount(int count) {
    setState(() {
      _chatStatusCount = count;
    });
  }

  @override
  void dispose() {
    _cartItemsSubscription?.cancel(); // Cancel the stream subscription
    super.dispose();
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activePage = const HomepageScreen();
    var activePageTitle = 'Homepage';

    if (_selectedPageIndex == 1) {
      activePage = const AccountDetailsScreen();
      activePageTitle = 'Account Settings';
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            Size.fromHeight(35.0 + MediaQuery.of(context).padding.top),
        child: AppBar(
          title: Text(activePageTitle),
          toolbarHeight: 56.0,
          backgroundColor:
              const Color.fromRGBO(231, 240, 242, 1), // Set initial color
          flexibleSpace: const FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
          ),
          elevation: 0,
          actions: activePageTitle == 'Homepage'
              ? [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        if (_cartItemCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.message), // Add the chat icon
                        if (_chatStatusCount > 0) // Display chat status count
                          Positioned(
                            top: 0,
                            right: 0,
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
                                _chatStatusCount.toString(),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserChatListScreen()),
                      );
                    },
                  ),
                ]
              : [
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.shopping_cart),
                        if (_cartItemCount > 0)
                          Positioned(
                            top: 0,
                            right: 0,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.message), // Add the chat icon
                        if (_chatStatusCount > 0) // Display chat status count
                          Positioned(
                            top: 0,
                            right: 0,
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
                                _chatStatusCount.toString(),
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserChatListScreen()),
                      );
                    },
                  ),
                ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            pinned: true,
            toolbarHeight: 0,
            backgroundColor:
                Color.fromRGBO(231, 240, 242, 1), // Set initial color
          ),
          SliverFillRemaining(
            child: activePage,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HomePage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
