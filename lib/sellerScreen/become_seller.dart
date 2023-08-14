import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/sellerScreen/seller_home.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

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
  File? _imageFile;

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
        ),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    } else {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.grey),
        ),
        child: const Center(
          child: Text('No Image Selected'),
        ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No image selected'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _submitRegistration(BuildContext context, String userId) async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final companyName = companyNameController.text;
    final registrationNumber = registrationNumberController.text;
    final shopName = shopNameController.text;
    final pickupAddress = pickupAddressController.text;
    final email = emailController.text;
    final phoneNumber = phoneNumberController.text;

    try {
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('sellers_images')
            .child('$userId.jpg');
        await storageRef.putFile(File(_imageFile!.path));
        final imageUrl = await storageRef.getDownloadURL();

        int autoIncrementedNumber = await _getNextAutoIncrementNumber();

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
          'image_url': imageUrl,
        });
      }

      companyNameController.clear();
      registrationNumberController.clear();
      shopNameController.clear();
      pickupAddressController.clear();
      emailController.clear();
      phoneNumberController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully registered as a seller!'),
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
      );
    } catch (error) {
      // Handle errors
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
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
                if (_imageFile != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(File(_imageFile!.path)),
                  ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: const Text('Pick from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: const Text('Take Photo'),
                ),
                const SizedBox(height: 16.0),
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
