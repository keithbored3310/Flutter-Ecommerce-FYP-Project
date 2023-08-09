import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/brand.dart';
import 'package:flutter/services.dart';

class AddBrandPage extends StatefulWidget {
  const AddBrandPage({super.key});

  @override
  State<AddBrandPage> createState() => _AddBrandPageState();
}

class _AddBrandPageState extends State<AddBrandPage> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  String? _errorMessage;
  bool _isAddingBrand = false; // Track whether brand is being added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Brand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand Name'),
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
                    return 'Please enter a brand name';
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
                    onPressed: _isAddingBrand ? null : _addBrand,
                    child: _isAddingBrand
                        ? const CircularProgressIndicator() // Show CircularProgressIndicator when adding brand
                        : const Text('Add Brand'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addBrand() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingBrand = true;
        _errorMessage = null; // Reset error message
      });

      // Form is valid, check if brand name already exists (case-insensitive)
      Brand? existingBrand = await _checkBrandName(_brandController.text);
      if (existingBrand != null) {
        setState(() {
          _errorMessage = 'Brand name already exists';
          _isAddingBrand = false;
        });
      } else {
        // Brand name is valid, add the brand to the Firestore collection
        addBrandToFirestore(_brandController.text);

        // Show a Snackbar to indicate successful brand addition
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait for the Snackbar to disappear, then return to the previous page
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    }
  }

  Future<Brand?> _checkBrandName(String brandName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('brands')
        .where('brand',
            isEqualTo: brandName.toLowerCase()) // Case-insensitive check
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var brandDoc = querySnapshot.docs.first;
      return Brand(
        id: brandDoc.id,
        brand: brandDoc.get('brand'),
      );
    }

    return null;
  }

  void addBrandToFirestore(String brandName) async {
    // Get the next auto-incremented number
    int autoIncrementedNumber = await _getNextAutoIncrementNumber();

    // Add the brand with the auto-incremented number to the Firestore collection
    FirebaseFirestore.instance.collection('brands').add({
      'id': autoIncrementedNumber,
      'brand': brandName,
    });
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('brands_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('brands_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }
}
