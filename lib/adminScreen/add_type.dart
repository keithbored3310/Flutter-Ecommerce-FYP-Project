import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/type.dart';
import 'package:flutter/services.dart';

class AddTypePage extends StatefulWidget {
  const AddTypePage({super.key});

  @override
  State<AddTypePage> createState() => _AddTypePageState();
}

class _AddTypePageState extends State<AddTypePage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  String? _errorMessage;
  bool _isAddingType = false; // Track whether type is being added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type Name'),
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
                    return 'Please enter a type name';
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
                    onPressed: _isAddingType ? null : _addType,
                    child: _isAddingType
                        ? const CircularProgressIndicator() // Show CircularProgressIndicator when adding brand
                        : const Text('Add Type'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addType() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingType = true;
        _errorMessage = null; // Reset error message
      });

      // Form is valid, check if brand name already exists (case-insensitive)
      Type? existingBrand = await _checkTypeName(_typeController.text);
      if (existingBrand != null) {
        setState(() {
          _errorMessage = 'Brand name already exists';
          _isAddingType = false;
        });
      } else {
        // Brand name is valid, add the brand to the Firestore collection
        addTypeToFirestore(_typeController.text);

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

  Future<Type?> _checkTypeName(String typeName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('types')
        .where('type', isEqualTo: typeName.toLowerCase())
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var typeDoc = querySnapshot.docs.first;
      return Type(
        id: typeDoc.id,
        type: typeDoc.get('type'),
      );
    }

    return null;
  }

  void addTypeToFirestore(String typeName) async {
    int autoIncrementedNumber = await _getNextAutoIncrementNumber();

    FirebaseFirestore.instance.collection('types').add({
      'id': autoIncrementedNumber,
      'type': typeName,
    });
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('types_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('types_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }
}
