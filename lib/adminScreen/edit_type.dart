import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTypePage extends StatefulWidget {
  const EditTypePage({super.key, required this.typeName});
  final String typeName;

  @override
  State<EditTypePage> createState() => _EditTypePageState();
}

class _EditTypePageState extends State<EditTypePage> {
  late TextEditingController _newTypeController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newTypeController = TextEditingController(text: widget.typeName);
  }

  @override
  void dispose() {
    _newTypeController.dispose();
    super.dispose();
  }

  void _updateTypeName(String newTypeName) {
    setState(() {
      _isSaving = true;
    });
    // Update the Type name in Firestore using the document ID
    FirebaseFirestore.instance
        .collection('types')
        .where('type', isEqualTo: widget.typeName)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        FirebaseFirestore.instance.collection('types').doc(documentID).update({
          'type': newTypeName,
        }).then((_) async {
          // Type name updated successfully
          // You can add a snackbar or any other UI feedback here
          // After updating, pop the page and pass the new Type name to the previous screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Type updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context, newTypeName);
        }).catchError((error) {
          // Error occurred while updating the Type name
          print('Error updating Type name: $error');
        });
      } else {
        // Type with the original name not found in Firestore
        print('Type not found in Firestore');
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
        title: const Text('Edit Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: widget.typeName,
              enabled: false, // Disable editing for the original Type name
              decoration: const InputDecoration(labelText: 'Old Type Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newTypeController,
              decoration: const InputDecoration(labelText: 'New Type Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      String newTypeName = _newTypeController.text;
                      _updateTypeName(newTypeName);
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
