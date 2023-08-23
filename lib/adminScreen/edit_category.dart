import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCategoryPage extends StatefulWidget {
  const EditCategoryPage({Key? key, required this.categoryName})
      : super(key: key);
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

    // Step 1: Update the category name in the 'categories' collection
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
        }).then((_) {
          // Step 2: Update the category name in the 'products' collection
          FirebaseFirestore.instance
              .collection('products')
              .where('category', isEqualTo: widget.categoryName)
              .get()
              .then((productQuerySnapshot) {
            if (productQuerySnapshot.docs.isNotEmpty) {
              for (var productDoc in productQuerySnapshot.docs) {
                String productId = productDoc.id;
                FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .update({
                  'category': newCategoryName,
                }).catchError((error) {
                  print('Error updating product category: $error');
                });
              }
            }
          }).catchError((error) {
            print('Error querying products: $error');
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context, newCategoryName);
          });
        }).catchError((error) {
          print('Error updating category name: $error');
        });
      } else {
        print('Category not found in Firestore');
      }

      setState(() {
        _isSaving = false;
      });
    }).catchError((error) {
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
              enabled: false,
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
                  : () {
                      String newCategoryName = _newCategoryController.text;
                      _updateCategoryName(newCategoryName);
                    },
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
