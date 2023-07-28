//build account setting screen
import 'package:flutter/material.dart';
import 'package:ecommerce/widget/button_widget.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ButtonWidget(
                  icon: Icons.security,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'Account Security',
                  onPressed: () {},
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
                  icon: Icons.emoji_people,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'About Us',
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
