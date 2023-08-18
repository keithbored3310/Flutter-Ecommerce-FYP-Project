import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Our Spare Parts Application!',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'At Spare Parts, we are dedicated to providing high-quality spare parts for all your vehicle needs. With a wide range of products and a commitment to excellent customer service, we strive to be your go-to destination for all your spare parts requirements.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Our mission is to ensure that your vehicles run smoothly and efficiently by offering genuine and reliable spare parts. We understand the importance of keeping your vehicles in top condition, and we are here to support you every step of the way.',
            ),
            SizedBox(height: 16.0),
            Text(
              'Thank you for choosing Spare Parts for your automotive needs!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
