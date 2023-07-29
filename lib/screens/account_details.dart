import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce/widget/button_widget.dart';
import 'package:ecommerce/widget/delivery_button.dart';
import 'package:ecommerce/userScreen/account_settings.dart';
import 'package:ecommerce/screens/become_seller.dart';
import 'package:ecommerce/userScreen/delivery_page.dart';
import 'package:ecommerce/screens/favorite_product.dart';
import 'package:ecommerce/screens/product_category.dart';
import 'package:ecommerce/userScreen/user_activity.dart';
import 'package:ecommerce/widget/data_fetcher.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() {
    return _AccountDetailsScreenState();
  }
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 75, // Adjust the height as needed
            child: FirestoreDataFetcher(
              userId: FirebaseAuth.instance.currentUser!.uid,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPage(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: DeliveryButton(
                  icon: Icons.card_giftcard,
                  label: 'To Ship',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPage(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: DeliveryButton(
                  icon: Icons.fire_truck,
                  label: 'To Receive',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPage(),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: DeliveryButton(
                  icon: Icons.star,
                  label: 'To Rate',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeliveryPage(),
                      ),
                    );
                  },
                ),
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
                label: 'Become Seller',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerRegistrationScreen(),
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
            thickness: 2.0, // Set the line width
            color: Colors.black, // Set the line color
          ),
          Row(
            children: [
              ButtonWidget(
                icon: Icons.category,
                trailingIcon: Icons.arrow_forward_ios,
                label: 'Category',
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
            thickness: 2.0, // Set the line width
            color: Colors.black, // Set the line color
          ),
          Row(
            children: [
              ButtonWidget(
                icon: Icons.local_activity,
                trailingIcon: Icons.arrow_forward_ios,
                label: 'Activity',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ActivityScreen(),
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
                icon: Icons.favorite,
                trailingIcon: Icons.arrow_forward_ios,
                label: 'Favorite Item',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FavoriteProductScreen(),
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
    );
  }
}
