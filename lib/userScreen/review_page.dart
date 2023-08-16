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
    Key? key,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double productRating = 5;
  double sellerRating = 5;
  TextEditingController commentController = TextEditingController();
  String imageUrl = ''; // To store the fetched image URL
  String productName = ''; // To store the fetched product name
  String productId = ''; // To store the fetched product ID
  String sellerId = ''; // To store the fetched seller ID
  File? _pickedImage; // Store the picked image
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
          title: Text('Confirm Action'),
          content: Text('Are you sure you want to give up giving reviews?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Navigate back to the previous page
              },
              child: Text('Give Up'),
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
    print('Uploading review image...');
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('review_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(imageFile);

      // Wait for the upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      if (snapshot.state == TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();
        print('Review Image uploaded. Download URL: $downloadURL');
        return downloadURL;
      } else {
        print('Failed to upload review image.');
        return null;
      }
    } catch (e) {
      print('Error uploading review image: $e');
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
      print('the userOrderId: ${widget.userOrderId}');

      // Check if the user order document exists
      final userOrderSnapshot = await userOrderDoc.get();
      if (userOrderSnapshot.exists) {
        // Update the document to add the 'isRated' field
        await userOrderDoc.set({'isRated': true}, SetOptions(merge: true));
      } else {
        print('User order document does not exist');
      }
    } catch (e) {
      print('Error updating user order isRated: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            showBackConfirmationDialog(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    width: 70, // Adjust the width as needed
                    height: 70, // Adjust the height as needed
                  ),
                SizedBox(width: 8),
                Text(
                  productName,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(
              thickness: 2.0, // Set the line width
              color: Colors.black, // Set the line color
            ),
            Text(
              'Product Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5, // Default rating value
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  productRating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Seller Rating',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 5, // Default rating value
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  sellerRating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Upload Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              children: [
                if (_pickedImage != null)
                  Image.file(
                    _pickedImage!,
                    width: 200, // Set the width to the desired size
                    height: 200, // Set the height to the desired size
                    fit: BoxFit
                        .cover, // Maintain aspect ratio and cover the space
                  ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text('Use Camera'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text('Pick from Gallery'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Leave a Comment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: commentController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your comment...',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null // Disable the button if submitting
                  : () async {
                      // Set isSubmitting to true when submitting
                      setState(() {
                        isSubmitting = true;
                      });

                      // Get the image URL from the uploaded image
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
                        // Update the existing review
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
                          'productId': productId, // Add this field
                          'sellerId': sellerId, // Add this field
                        });
                      }

                      // Add the 'isRated' field to the user order document
                      await _updateUserOrderIsRated();

                      // Show a snackbar when the review is added successfully
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Review added successfully.'),
                        ),
                      );

                      // Set isSubmitting back to false
                      setState(() {
                        isSubmitting = false;
                      });

                      // Navigate back to the previous page
                      Navigator.pop(context);
                    },
              child: isSubmitting
                  ? CircularProgressIndicator() // Show progress indicator while submitting
                  : Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
