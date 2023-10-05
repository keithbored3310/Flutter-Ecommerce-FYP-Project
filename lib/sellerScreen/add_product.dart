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
  String? _selectedBrand;
  String? _selectedCategory;
  String? _selectedType;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _partNumberController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  bool _isSaving = false;
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
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    const bool isImageMandatory = true;

    if (isImageMandatory && _imageFile == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Product Picture Required'),
            content: const Text('Please select a product picture.'),
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
      _isSaving = true;
    });

    try {
      final sellersId = _getCurrentUserId();

      if (sellersId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: User not authenticated'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      _selectedBrand ??= 'Others';
      _selectedCategory ??= 'Others';
      _selectedType ??= 'Others';

      final productsCollection =
          FirebaseFirestore.instance.collection('products');

      int autoIncrementedNumber = await _getNextAutoIncrementNumber();

      final newProductDoc = productsCollection.doc();

      final productData = {
        'id': autoIncrementedNumber,
        'sellersId': sellersId,
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
      };

      // Save the data to Firestore
      await newProductDoc.set(productData);
      // print('Uploading image to Firebase Storage...');
      // Upload image to Firebase Storage and get the image URL
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('product_images/${newProductDoc.id}.jpg');
        final uploadTask = storageRef.putFile(_imageFile!);
        final downloadURL = await (await uploadTask).ref.getDownloadURL();
        // print('Image uploaded. Download URL: $downloadURL');
        // Add the image URL to the product data
        productData['imageUrl'] = downloadURL;
        await newProductDoc.update(productData);
      } else {
        // print('No image file to upload.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that may occur
      // print('Error saving product: $e');
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
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('products_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;
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
              BrandDropdown(
                selectedBrand: _selectedBrand,
                onBrandChanged: (String? brand) {
                  setState(() {
                    _selectedBrand = brand;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              CategoryDropdown(
                selectedCategory: _selectedCategory,
                onCategoryChanged: (String? category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TypeDropdown(
                selectedType: _selectedType,
                onTypeChanged: (String? type) {
                  setState(() {
                    _selectedType = type;
                  });
                },
              ),
              const SizedBox(height: 16.0),
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
              TextFormField(
                controller: _discountedPriceController,
                enabled: false,
                decoration:
                    const InputDecoration(labelText: 'Discounted Price (RM)'),
              ),
              const SizedBox(height: 16.0),
              _buildImagePreview(),
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
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() == true) {
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
