//build a screen to display registration to become seller, the body need to have add company name row, business registration number row, shop name row, pickup address row, email row and phone number row. , the bottom of the screen should have a button to submit the registration

import 'package:ecommerce/sellerScreen/seller_home.dart';
import 'package:flutter/material.dart';

class SellerRegistrationScreen extends StatelessWidget {
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController pickupAddressController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: registrationNumberController,
              decoration: InputDecoration(labelText: 'Registration Number'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: shopNameController,
              decoration: InputDecoration(labelText: 'Shop Name'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: pickupAddressController,
              decoration: InputDecoration(labelText: 'Pickup Address'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // // Add submit registration functionality here
                // // You can access the entered values using the text controllers
                // // Example: validate and send registration data to server
                // final companyName = companyNameController.text;
                // final registrationNumber = registrationNumberController.text;
                // final shopName = shopNameController.text;
                // final pickupAddress = pickupAddressController.text;
                // final email = emailController.text;
                // final phoneNumber = phoneNumberController.text;

                // // Perform registration logic here

                // // Clear the text fields after submission
                // companyNameController.clear();
                // registrationNumberController.clear();
                // shopNameController.clear();
                // pickupAddressController.clear();
                // emailController.clear();
                // phoneNumberController.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SellerHomeScreen()),
                );
              },
              child: Text('Submit Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
