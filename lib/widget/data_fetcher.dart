import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/userScreen/account_security.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/user.dart';

class FirestoreDataFetcher extends StatefulWidget {
  final String userId;

  const FirestoreDataFetcher({required this.userId, super.key});

  @override
  State<FirestoreDataFetcher> createState() => _FirestoreDataFetcherState();
}

class _FirestoreDataFetcherState extends State<FirestoreDataFetcher> {
  User? _user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data != null) {
            _user = User.fromFirestore(data, widget.userId);
          }

          return _user != null
              ? Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserDetailsScreen(userId: widget.userId),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundImage: NetworkImage(_user!.imageUrl),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            _user!.username,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Text('User data not found');
        },
      ),
    );
  }
}
