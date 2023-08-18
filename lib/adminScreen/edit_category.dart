import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({super.key, required this.categoryName});
  final String categoryName;

  @override
  State<EditCategoryPage> createState() => _EditCategoryPageState();
}

class _EditCategoryPageState extends State<EditCategoryPage> {
  late TextEditingController _newCategoryController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newCategoryController = TextEditingController(text: widget.categoryName);
  }

  @override
  void dispose() {
    _newCategoryController.dispose();
    super.dispose();
  }

  void _updateCategoryName(String newCategoryName) {
    setState(() {
      _isSaving = true;
    });
    // Update the category name in Firestore using the document ID
    FirebaseFirestore.instance
        .collection('categories')
        .where('category', isEqualTo: widget.categoryName)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        FirebaseFirestore.instance
            .collection('categories')
            .doc(documentID)
            .update({
          'category': newCategoryName,
        }).then((_) async {
          // Category name updated successfully
          // You can add a snackbar or any other UI feedback here
          // After updating, pop the page and pass the new category name to the previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context, newCategoryName);
        }).catchError((error) {
          // Error occurred while updating the category name
          print('Error updating category name: $error');
        });
      } else {
        // Category with the original name not found in Firestore
        print('Category not found in Firestore');
      }
      setState(() {
        _isSaving = false;
      });
    }).catchError((error) {
      // Error occurred while querying Firestore
      print('Error querying Firestore: $error');
      setState(() {
        _isSaving = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: widget.categoryName,
              enabled: false, // Disable editing for the original category name
              decoration: const InputDecoration(labelText: 'Old Category Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newCategoryController,
              decoration: const InputDecoration(labelText: 'New Category Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      String newCategoryName = _newCategoryController.text;
                      _updateCategoryName(newCategoryName);
                    },
              child: _isSaving
                  ? const CircularProgressIndicator() // Show CircularProgressIndicator while saving
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
