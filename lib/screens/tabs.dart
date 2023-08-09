import 'package:ecommerce/screens/search_screen.dart';
import 'package:flutter/material.dart';

import 'package:ecommerce/screens/account_details.dart';
import 'package:ecommerce/screens/homepage.dart';
import 'package:ecommerce/screens/cart_screen.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({Key? key}) : super(key: key);

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

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
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                ]
              : [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CartScreen()),
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
