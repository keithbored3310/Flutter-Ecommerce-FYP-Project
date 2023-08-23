import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTypePage extends StatefulWidget {
  const EditTypePage({Key? key, required this.typeName}) : super(key: key);
  final String typeName;

  @override
  _EditTypePageState createState() => _EditTypePageState();
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

  Future<void> _updateTypeName(String newTypeName) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Update the Type name in Firestore using the document ID
      final typeQuerySnapshot = await FirebaseFirestore.instance
          .collection('types')
          .where('type', isEqualTo: widget.typeName)
          .get();

      if (typeQuerySnapshot.docs.isNotEmpty) {
        final typeDocumentID = typeQuerySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('types')
            .doc(typeDocumentID)
            .update({
          'type': newTypeName,
        });

        // Now, update the products collection where 'type' matches the old type name
        final productQuerySnapshot = await FirebaseFirestore.instance
            .collection('products')
            .where('type', isEqualTo: widget.typeName)
            .get();

        if (productQuerySnapshot.docs.isNotEmpty) {
          for (final productDoc in productQuerySnapshot.docs) {
            final productId = productDoc.id;
            await FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .update({
              'type': newTypeName,
            });
          }
        }

        // Type name updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Type updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, newTypeName);
      } else {
        // Type with the original name not found in Firestore
        print('Type not found in Firestore');
      }
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating Type name: $error');

      // Show an error message or handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating Type name.'),
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
              enabled: false,
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
                      final newTypeName = _newTypeController.text;
                      await _updateTypeName(newTypeName);
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
