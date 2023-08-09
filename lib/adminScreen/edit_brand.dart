import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBrandPage extends StatefulWidget {
  const EditBrandPage({super.key, required this.brandName});
  final String brandName;

  @override
  State<EditBrandPage> createState() => _EditBrandPageState();
}

class _EditBrandPageState extends State<EditBrandPage> {
  late TextEditingController _newBrandController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newBrandController = TextEditingController(text: widget.brandName);
  }

  @override
  void dispose() {
    _newBrandController.dispose();
    super.dispose();
  }

  void _updateBrandName(String newBrandName) {
    setState(() {
      _isSaving = true;
    });

    FirebaseFirestore.instance
        .collection('brands')
        .where('brand', isEqualTo: widget.brandName)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        FirebaseFirestore.instance.collection('brands').doc(documentID).update({
          'brand': newBrandName,
        }).then((_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Brand updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context, newBrandName);
        }).catchError((error) {
          print('Error updating brand name: $error');
        });
      } else {
        print('Brand not found in Firestore');
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
        title: const Text('Edit Brand'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: widget.brandName,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Old Brand Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newBrandController,
              decoration: const InputDecoration(labelText: 'New Brand Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      String newBrandName = _newBrandController.text;
                      _updateBrandName(newBrandName);
                    },
              child: _isSaving
                  ? CircularProgressIndicator() // Show CircularProgressIndicator while saving
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
