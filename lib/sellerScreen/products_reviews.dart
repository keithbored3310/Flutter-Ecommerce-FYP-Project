import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsReviewPage extends StatelessWidget {
  final String productId;

  const ProductsReviewPage({super.key, required this.productId});

  Widget _buildRatingStars(dynamic rating) {
    if (rating == null || rating is! num) {
      return const Text('N/A');
    }

    double ratingValue = rating.toDouble();
    if (ratingValue < 0 || ratingValue > 5) {
      return const Text('N/A');
    }

    int starCount = ratingValue.round();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        starCount,
        (index) => const Icon(
          Icons.star,
          color: Colors.yellow,
        ),
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchProductReviewsStream() {
    return FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: 4)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Product Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _fetchProductReviewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final reviewData = snapshot.data!.docs[index].data();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(reviewData['imageUrl']),
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(reviewData['username']),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reviewData['reviewImageUrl'].isNotEmpty)
                          Image.network(
                            reviewData['reviewImageUrl'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        Text(reviewData['comment']),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRatingStars(reviewData['productRating']),
                            Text(
                              reviewData['timestamp'].toDate().toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
