import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditSellerScreen extends StatefulWidget {
  final String sellerId;

  const EditSellerScreen({required this.sellerId, super.key});

  @override
  _EditSellerScreenState createState() => _EditSellerScreenState();
}

class _EditSellerScreenState extends State<EditSellerScreen> {
  TextEditingController _shopNameController = TextEditingController();
  TextEditingController _pickupAddressController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();

  ImageProvider<Object>? _avatarImage;

  @override
  void initState() {
    super.initState();
    // Fetch seller data from Firestore and populate the text fields
    _fetchSellerData();
    print('Seller ID in this page: ${widget.sellerId}');
  }

  void _fetchSellerData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerId)
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> sellerData =
            snapshot.data() as Map<String, dynamic>;

        setState(() {
          _shopNameController.text = sellerData['shopName'] ?? '';
          _pickupAddressController.text = sellerData['pickupAddress'] ?? '';
          _emailController.text = sellerData['email'] ?? '';
          _phoneNumberController.text = sellerData['phoneNumber'] ?? '';

          // Set the avatar image based on the imageUrl if it exists
          if (sellerData.containsKey('image_url') &&
              sellerData['image_url'] != null &&
              sellerData['image_url'].isNotEmpty) {
            _avatarImage = NetworkImage(sellerData['image_url']);
          } else {
            _avatarImage = const AssetImage('assets/images/default-avatar.png');
          }
        });
      }
    } catch (e) {
      print('Error fetching seller data: $e');
    }
  }

  void _updateSellerData() async {
    try {
      // Update the seller data fields in Firestore
      await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerId)
          .update({
        'shopName': _shopNameController.text.trim(),
        'pickupAddress': _pickupAddressController.text.trim(),
        'email': _emailController.text.trim(),
        'phoneNumber': _phoneNumberController.text.trim(),
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Seller information updated successfully')),
      );

      // If a new profile image was selected, upload it to Firebase Storage
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('sellers_images')
            .child('${widget.sellerId}.jpg');
        await storageRef.putFile(_profileImage!);

        // Get the download URL of the uploaded image
        final imageUrl = await storageRef.getDownloadURL();

        // Update the 'image_url' field in Firestore
        await FirebaseFirestore.instance
            .collection('sellers')
            .doc(widget.sellerId)
            .update({
          'image_url': imageUrl,
        });
      }

      // Delay navigation to previous screen after SnackBar disappears
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      // Show an error message
      print('Error updating seller data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content:
                const Text('Are you sure you want to discard the changes?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<void> _pickImageFromCamera() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
        _avatarImage = FileImage(_profileImage!);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
        _avatarImage = FileImage(_profileImage!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Seller Information'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                _updateSellerData();
                // Call the function to upload the profile image here if needed
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Call the function to pick an image here
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _avatarImage,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Picture'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Pick from Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(labelText: 'Shop Name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pickupAddressController,
                decoration: const InputDecoration(labelText: 'Pickup Address'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
