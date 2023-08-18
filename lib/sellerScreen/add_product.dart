import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:ecommerce/widget/brand_drop_down.dart';
import 'package:ecommerce/widget/category_drop_down.dart';
import 'package:ecommerce/widget/type_drop_down.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBrand; // Nullable selected brand
  String? _selectedCategory; // Nullable selected category
  String? _selectedType; // Nullable selected type

  // Other form fields and their controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  bool _isSaving = false;

  // Image picker variables
  File? _imageFile;

  String? _getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return null;
  }

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

  // Method to calculate discounted price based on price and discount
  void _calculateDiscountPrice() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discountPercentage = double.tryParse(_discountController.text) ?? 0.0;
    final discountPrice = price * (1 - (discountPercentage / 100));
    setState(() {
      _discountedPriceController.text = discountPrice.toStringAsFixed(2);
    });
  }

  // Method to handle image selection from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    } else {
      // No image was selected, show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No image selected'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Method to save the product details to Firestore
  // Method to save the product details to Firestore
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      // Validation failed or already saving, return early
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final sellersId = _getCurrentUserId(); // Get the current user's ID

      // If sellersId is null, display an error message and return
      if (sellersId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User not authenticated'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check if brand, category, and type are null, and set them to 'Other' if needed
      _selectedBrand ??= 'Others';
      _selectedCategory ??= 'Others';
      _selectedType ??= 'Others';

      // Get a reference to the Firestore collection where you want to store the products
      final productsCollection =
          FirebaseFirestore.instance.collection('products');

      // Get the next auto-incremented number
      int autoIncrementedNumber = await _getNextAutoIncrementNumber();

      // Create a new document for the product
      final newProductDoc = productsCollection.doc();

      // Prepare the data to be saved
      final productData = {
        'id': autoIncrementedNumber,
        'sellersId': sellersId, // Add the sellersId to the product data
        'brand': _selectedBrand,
        'category': _selectedCategory,
        'type': _selectedType,
        'name': _nameController.text,
        'description': _descriptionController.text,
        'partNumber': _partNumberController.text,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'discountedPrice':
            double.tryParse(_discountedPriceController.text) ?? 0.0,
        // Add more fields for other form fields
      };

      // Save the data to Firestore
      await newProductDoc.set(productData);
      print('Uploading image to Firebase Storage...');
      // Upload image to Firebase Storage and get the image URL
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${newProductDoc.id}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final downloadURL = await (await uploadTask).ref.getDownloadURL();
        print('Image uploaded. Download URL: $downloadURL');
        // Add the image URL to the product data
        productData['imageUrl'] = downloadURL;
        await newProductDoc.update(productData);
      } else {
        print('No image file to upload.');
      }

      // Show a success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      // Wait for a short duration to display the success message
      await Future.delayed(const Duration(seconds: 2));

// Navigate back to the previous page
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that may occur
      print('Error saving product: $e');
      // Show an error message or handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving product'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('products_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('products_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Drop-down list for brands
              BrandDropdown(
                selectedBrand: _selectedBrand,
                onBrandChanged: (String? brand) {
                  setState(() {
                    _selectedBrand = brand;
                  });
                },
                // validator: _validateBrand,
              ),

              const SizedBox(height: 16.0), // Add spacing between the fields
              CategoryDropdown(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (String? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                // validator: _validateCategory,
              ),

              const SizedBox(height: 16.0), // Add spacing between the fields
              TypeDropdown(
                selectedType: _selectedType,
                onTypeChanged: (String? type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
                // validator: _validateType,
              ),
              const SizedBox(height: 16.0),
              // Add more form fields and buttons as needed
              // Name TextField
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
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
              // Add more form fields and buttons as needed
              // Name TextField
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
              // Part Number TextField
              TextFormField(
                controller: _partNumberController,
                decoration: const InputDecoration(labelText: 'Part Number'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Part Number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Quantity TextField
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Price TextField
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  _calculateDiscountPrice();
                },
                decoration: const InputDecoration(labelText: 'Price (RM)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Please enter a valid price greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Discount TextField
              TextFormField(
                controller: _discountController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  _calculateDiscountPrice();
                },
                decoration:
                    const InputDecoration(labelText: 'Discount Value (%)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a discount value';
                  }
                  final discountValue = double.tryParse(value);
                  if (discountValue == null ||
                      discountValue < 0 ||
                      discountValue > 100) {
                    return 'Please enter a valid discount value between 0 and 100';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16.0),
              // Display discounted price
              TextFormField(
                controller: _discountedPriceController,
                enabled: false,
                decoration:
                    const InputDecoration(labelText: 'Discounted Price (RM)'),
              ),
              const SizedBox(height: 16.0),
              _buildImagePreview(),
              // Image picker buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.camera);
                      },
                      child: const Text('Take Photo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _pickImage(ImageSource.gallery);
                      },
                      child: const Text('Choose from Gallery'),
                    ),
                  ),
                ],
              ),
              // Save button
              // Save button
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() == true) {
                          // The form is valid, proceed with saving the product
                          _saveProduct();
                        }
                      },
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
