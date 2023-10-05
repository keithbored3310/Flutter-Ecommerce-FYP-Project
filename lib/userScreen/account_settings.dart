import 'package:ecommerce/screens/about_us.dart';
import 'package:ecommerce/userScreen/account_security.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/widget/button_widget.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  // Function to fetch the userId of the authenticated user
  void _fetchUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

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
                  onPressed: () {
                    if (_userId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailsScreen(userId: _userId!),
                        ),
                      );
                    } else {}
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
                  icon: Icons.emoji_people,
                  trailingIcon: Icons.arrow_forward_ios,
                  label: 'About Us',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AboutUsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
