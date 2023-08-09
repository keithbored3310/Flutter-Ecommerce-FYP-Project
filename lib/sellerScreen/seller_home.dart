import 'package:ecommerce/adminScreen/brand_screen.dart';
import 'package:ecommerce/adminScreen/category_screen.dart';
import 'package:ecommerce/adminScreen/type_screen.dart';
import 'package:ecommerce/sellerScreen/add_product.dart';
import 'package:ecommerce/sellerScreen/manage_product.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/widget/button_widget.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity, // Take full available width
              child: ButtonWidget(
                icon: Icons.fire_truck,
                trailingIcon: Icons.arrow_forward_ios,
                label: 'Manage Order',
                onPressed: () {
                  // Add your logic here for the "Manage Order" button
                },
              ),
            ),
            const Divider(
              thickness: 2.0, // Set the line width
              color: Colors.black, // Set the line color
            ), // Add spacing between the buttons
            SizedBox(
              width: double.infinity, // Take full available width
              child: ButtonWidget(
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
            ),
            const Divider(
              thickness: 2.0, // Set the line width
              color: Colors.black, // Set the line color
            ), // Add spacing between the buttons
            SizedBox(
              width: double.infinity, // Take full available width
              child: ButtonWidget(
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
            ),
            const Divider(
              thickness: 2.0, // Set the line width
              color: Colors.black, // Set the line color
            ), // Add spacing between the buttons
            SizedBox(
              width: double.infinity, // Take full available width
              child: ButtonWidget(
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
            ),
            const Divider(
              thickness: 2.0, // Set the line width
              color: Colors.black, // Set the line color
            ), // Add spacing between the buttons
            SizedBox(
              width: double.infinity, // Take full available width
              child: ButtonWidget(
                icon: Icons.store,
                trailingIcon: Icons.arrow_forward_ios,
                label: 'Add Type',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TypeScreen()),
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
