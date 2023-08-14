import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerInformationPage extends StatelessWidget {
  final String sellerId;

  const SellerInformationPage({required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seller Information'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('sellers')
            .doc(sellerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('Seller Not Found');
          }

          final sellerData = snapshot.data!.data()!;
          final companyName = sellerData['companyName'] ?? '';
          final email = sellerData['email'] ?? '';
          final phoneNumber = sellerData['phoneNumber'] ?? '';
          final pickupAddress = sellerData['pickupAddress'] ?? '';
          final registrationNumber = sellerData['registrationNumber'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Company Name',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$companyName',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$email',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phone Number',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$phoneNumber',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Address',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$pickupAddress',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registration Number',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$registrationNumber',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                const Divider(
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Colors.black,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
