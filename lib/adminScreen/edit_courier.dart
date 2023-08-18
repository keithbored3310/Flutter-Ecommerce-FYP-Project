import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCourierPage extends StatefulWidget {
  const EditCourierPage({super.key, required this.courierName});
  final String courierName;

  @override
  State<EditCourierPage> createState() => _EditCourierPageState();
}

class _EditCourierPageState extends State<EditCourierPage> {
  late TextEditingController _newCourierController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _newCourierController = TextEditingController(text: widget.courierName);
  }

  @override
  void dispose() {
    _newCourierController.dispose();
    super.dispose();
  }

  void _updateCourierName(String newCourierName) {
    setState(() {
      _isSaving = true;
    });

    FirebaseFirestore.instance
        .collection('couriers')
        .where('courier', isEqualTo: widget.courierName)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String documentID = querySnapshot.docs.first.id;
        FirebaseFirestore.instance
            .collection('couriers')
            .doc(documentID)
            .update({
          'courier': newCourierName,
        }).then((_) async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Courier updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pop(context, newCourierName);
        }).catchError((error) {
          print('Error updating courier name: $error');
        });
      } else {
        print('Courier not found in Firestore');
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
        title: const Text('Edit Courier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              initialValue: widget.courierName,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Old Courier Name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newCourierController,
              decoration: const InputDecoration(labelText: 'New Courier Name'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSaving
                  ? null
                  : () async {
                      String newCourierName = _newCourierController.text;
                      _updateCourierName(newCourierName);
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
