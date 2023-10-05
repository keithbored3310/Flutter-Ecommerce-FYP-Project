import 'package:ecommerce/screens/tabs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ReviewPage extends StatefulWidget {
  final String orderId;
  final String userOrderId;

  const ReviewPage({
    required this.orderId,
    required this.userOrderId,
    super.key,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double productRating = 5;
  double sellerRating = 5;
  TextEditingController commentController = TextEditingController();
  String imageUrl = '';
  String productName = '';
  String productId = '';
  String sellerId = '';
  File? _pickedImage;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchReviewData();
  }

  Future<void> fetchReviewData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('userOrderId', isEqualTo: widget.userOrderId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var reviewData = querySnapshot.docs[0].data() as Map<String, dynamic>;
      setState(() {
        imageUrl = reviewData['imageUrl'];
        productName = reviewData['productName'];
        productId = reviewData['productId'];
        sellerId = reviewData['sellerId'];
      });
    }
  }

  Future<void> showBackConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Action'),
          content:
              const Text('Are you sure you want to give up giving reviews?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Give Up'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    setState(() {
      if (pickedImage != null) {
        _pickedImage = File(pickedImage.path);
      }
    });
  }

  Future<String?> uploadReviewImage(File imageFile) async {
//    print('Uploading review image...');
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('review_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      if (snapshot.state == TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();
        // print('Review Image uploaded. Download URL: $downloadURL');
        return downloadURL;
      } else {
        // print('Failed to upload review image.');
        return null;
      }
    } catch (e) {
      // print('Error uploading review image: $e');
      return null;
    }
  }

  Future<void> _updateUserOrderIsRated() async {
    try {
      final userOrderDoc = FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .collection('userOrders')
          .doc(widget.userOrderId);
      final userOrderSnapshot = await userOrderDoc.get();
      if (userOrderSnapshot.exists) {
        await userOrderDoc.set({'isRated': true}, SetOptions(merge: true));
      } else {
        // print('User order document does not exist');
      }
    } catch (e) {
      // print('Error updating user order isRated: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showBackConfirmationDialog(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: 70,
                    height: 70,
                  ),
                const SizedBox(width: 8),
                Text(
                  productName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(
              thickness: 2.0,
              color: Colors.black,
            ),
            const Text(
              'Product Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  productRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Seller Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  sellerRating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                if (_pickedImage != null)
                  Image.file(
                    _pickedImage!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Use Camera'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Pick from Gallery'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Leave a Comment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your comment...',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      const bool isImageMandatory = true;

                      if (isImageMandatory && _pickedImage == null) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Review Picture Required'),
                              content:
                                  const Text('Please select a review picture.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      setState(() {
                        isSubmitting = true;
                      });
                      String? reviewImageUrl;
                      if (_pickedImage != null) {
                        reviewImageUrl = await uploadReviewImage(_pickedImage!);
                      }

                      final existingReviewQuery = await FirebaseFirestore
                          .instance
                          .collection('reviews')
                          .where('userOrderId', isEqualTo: widget.userOrderId)
                          .get();

                      String reviewId;
                      if (existingReviewQuery.docs.isNotEmpty) {
                        final existingReviewDoc =
                            existingReviewQuery.docs.first;
                        reviewId = existingReviewDoc.id;
                        await existingReviewDoc.reference.update({
                          'productRating': productRating,
                          'sellerRating': sellerRating,
                          'comment': commentController.text ?? '',
                          'reviewImageUrl': reviewImageUrl ?? '',
                          'status': 4,
                          'reviewId': reviewId,
                        });
                      } else {
                        // Add a new review
                        final newReviewRef = await FirebaseFirestore.instance
                            .collection('reviews')
                            .add({
                          'userOrderId': widget.userOrderId,
                          'productRating': productRating,
                          'sellerRating': sellerRating,
                          'comment': commentController.text ?? '',
                          'reviewImageUrl': reviewImageUrl ?? '',
                          'status': 4,
                          'productId': productId,
                          'sellerId': sellerId,
                        });
                      }
                      await _updateUserOrderIsRated();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Review added successfully.'),
                        ),
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TabsScreen()),
                      );
                      setState(() {
                        isSubmitting = false;
                      });
                    },
              child: isSubmitting
                  ? const CircularProgressIndicator() // Show progress indicator while submitting
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
