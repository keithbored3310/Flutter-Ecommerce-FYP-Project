import 'dart:io';

import 'package:ecommerce/widget/brand_drop_down.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:ecommerce/widget/category_drop_down.dart';
import 'package:ecommerce/widget/type_drop_down.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    required this.productId,
    required this.productData,
    super.key,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _partNumberController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _discountedPriceController =
      TextEditingController();
  String? _selectedBrand; // Nullable selected brand
  String? _selectedCategory; // Nullable selected category
  String? _selectedType; // Nullable selected type

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the text controllers with the current product details
    _nameController.text = widget.productData['name'];
    _descriptionController.text = widget.productData['description'];
    _partNumberController.text = widget.productData['partNumber'];
    _priceController.text = widget.productData['price'].toString();
    _quantityController.text = widget.productData['quantity'].toString();
    _discountController.text = widget.productData['discount'].toString();
    _discountedPriceController.text =
        widget.productData['discountedPrice'].toString();
    _selectedBrand = widget.productData['brand'];
    _selectedCategory = widget.productData['category'];
    _selectedType = widget.productData['type'];
  }

  void _calculateDiscountPrice() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final discountPercentage = double.tryParse(_discountController.text) ?? 0.0;
    final discountPrice = price * (1 - (discountPercentage / 100));
    setState(() {
      _discountedPriceController.text = discountPrice.toStringAsFixed(2);
    });
  }

  File? _imageFile;

  Widget _buildImagePreview() {
    if (_imageFile == null) {
      // Display the current image from the database
      return Image.network(
        widget.productData['imageUrl'],
        fit: BoxFit.cover,
      );
    } else {
      // Display the selected image from the picker
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage == null) return;

    final pickedImageFile = File(pickedImage.path);
    setState(() {
      _imageFile = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: _buildImagePreview(),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera),
                          label: const Text('Take Photo'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo),
                          label: const Text('Pick from Gallery'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    BrandDropdown(
                      selectedBrand: _selectedBrand,
                      onBrandChanged: (value) {
                        setState(() {
                          _selectedBrand = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    CategoryDropdown(
                      selectedCategory: _selectedCategory,
                      onCategoryChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TypeDropdown(
                      selectedType: _selectedType,
                      onTypeChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                      },
                    ),
                    // Name TextField
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Description TextField
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Part Number TextField
                    TextFormField(
                      controller: _partNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Part Number'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Price TextField
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        _calculateDiscountPrice();
                      },
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Quantity TextField
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Discount TextField
                    TextFormField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        _calculateDiscountPrice();
                      },
                      decoration: const InputDecoration(labelText: 'Discount'),
                      validator: (value) {
                        // Your validation logic here
                        // Return null if valid, an error message if not
                      },
                    ),
                    // Discounted Price TextField
                    TextFormField(
                      controller: _discountedPriceController,
                      enabled: false,
                      decoration:
                          const InputDecoration(labelText: 'Discounted Price'),
                    ),
                    const SizedBox(height: 16.0),
                    // Save button
                    ElevatedButton(
                      onPressed: _saveProductChanges,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveProductChanges() async {
    try {
      // Show a loading indicator while updating the product details
      setState(() {
        _isLoading = true;
      });

      // Upload the image to Firebase Storage if a new image was picked
      String imageUrl = widget.productData['imageUrl'];
      if (_imageFile != null) {
        final ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${widget.productId}.jpg');
        await ref.putFile(_imageFile!);
        imageUrl = await ref.getDownloadURL();
      }

      // Extract the values from the text controllers
      final updatedProductData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'partNumber': _partNumberController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'quantity': int.tryParse(_quantityController.text) ?? 0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'discountedPrice':
            double.tryParse(_discountedPriceController.text) ?? 0.0,
        'imageUrl': imageUrl, // Update the image URL
        'brand': _selectedBrand, // Update the brand field
        'category': _selectedCategory,
        'type': _selectedType,
        // Add more fields as needed
      };

      // Update the product details in Firestore
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update(updatedProductData);

      // Show a success message or handle the update success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product details updated successfully.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Wait for a short duration before popping the edit product page
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that may occur during the update process
      print('Error updating product details: $e');

      // Show an error message or handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating product details.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      // Remove the loading indicator when the process is completed
      setState(() {
        _isLoading = false;
      });
    }
  }
}
