import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/category.dart';
import 'package:flutter/services.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  String? _errorMessage;
  bool _isAddingCategory = false; // Track whether category is being added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^[a-zA-Z ]+$'),
                  ),
                ],
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Please enter a category name';
                  }
                  return _errorMessage;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel button pressed
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _isAddingCategory ? null : _addCategory,
                    child: _isAddingCategory
                        ? const CircularProgressIndicator() // Show CircularProgressIndicator when adding brand
                        : const Text('Add Category'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCategory() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingCategory = true;
        _errorMessage = null; // Reset error message
      });

      // Form is valid, check if brand name already exists (case-insensitive)
      Category? existingBrand =
          await _checkCategoryName(_categoryController.text);
      if (existingBrand != null) {
        setState(() {
          _errorMessage = 'Category name already exists';
          _isAddingCategory = false;
        });
      } else {
        // Brand name is valid, add the brand to the Firestore collection
        addCategoryToFirestore(_categoryController.text);

        // Show a Snackbar to indicate successful brand addition
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait for the Snackbar to disappear, then return to the previous page
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    }
  }

  Future<Category?> _checkCategoryName(String categoryName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('categories')
        .where('category', isEqualTo: categoryName.toLowerCase())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var categoryDoc = querySnapshot.docs.first;
      return Category(
        id: categoryDoc.id,
        category: categoryDoc.get('category'),
      );
    }

    return null;
  }

  void addCategoryToFirestore(String categoryName) async {
    int autoIncrementedNumber = await _getNextAutoIncrementNumber();
    FirebaseFirestore.instance.collection('categories').add({
      'id': autoIncrementedNumber,
      'category': categoryName,
    });
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('categories_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('categories_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }
}
