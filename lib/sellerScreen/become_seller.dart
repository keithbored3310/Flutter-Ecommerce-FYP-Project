import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/sellerScreen/seller_home.dart';
import 'package:flutter/services.dart';

class SellerRegistrationScreen extends StatefulWidget {
  @override
  _SellerRegistrationScreenState createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState extends State<SellerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  bool _isSubmitting = false;

  void _submitRegistration(BuildContext context, String userId) async {
    // Validate all text fields
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      // Validation failed, return early
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Get the entered values from the text controllers
    final companyName = companyNameController.text;
    final registrationNumber = registrationNumberController.text;
    final shopName = shopNameController.text;
    final pickupAddress = pickupAddressController.text;
    final email = emailController.text;
    final phoneNumber = phoneNumberController.text;
    int autoIncrementedNumber = await _getNextAutoIncrementNumber();
    // Create a new seller document in the "sellers" collection
    final sellerDocRef =
        FirebaseFirestore.instance.collection('sellers').doc(userId);
    await sellerDocRef.set({
      'id': autoIncrementedNumber,
      'sellerId': userId,
      'companyName': companyName,
      'registrationNumber': registrationNumber,
      'shopName': shopName,
      'pickupAddress': pickupAddress,
      'email': email,
      'phoneNumber': phoneNumber,
    });

    // Clear the text fields after submission
    companyNameController.clear();
    registrationNumberController.clear();
    shopNameController.clear();
    pickupAddressController.clear();
    emailController.clear();
    phoneNumberController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully registered as a seller!'),
        duration: const Duration(seconds: 2),
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    // Navigate to the seller home screen after registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
    );
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('sellers_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('sellers_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle the case when the user is not authenticated.
      // You might want to show an error message or redirect to the login screen.
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated.'),
        ),
      );
    }

    final userId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Registration'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: companyNameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a company name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: registrationNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Registration Number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a registration number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: shopNameController,
                  decoration: const InputDecoration(labelText: 'Shop Name'),
                  enableSuggestions: false,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length < 4) {
                      return 'Please enter at least 4 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: pickupAddressController,
                  decoration:
                      const InputDecoration(labelText: 'Pickup Address'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty ||
                        !value.contains('@')) {
                      return 'Please enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    final phoneRegex = RegExp(r'^\+?0[0-9]{1,2}[0-9]{7,8}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return 'Please enter a valid Malaysia phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _submitRegistration(context, userId),
                  child: _isSubmitting
                      ? CircularProgressIndicator() // Show CircularProgressIndicator when submitting
                      : const Text('Submit Registration'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
