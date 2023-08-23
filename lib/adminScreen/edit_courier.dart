import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCourierPage extends StatefulWidget {
  const EditCourierPage({Key? key, required this.courierName})
      : super(key: key);
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

  Future<void> _updateCourierName(String newCourierName) async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Update the Courier name in Firestore using the document ID
      final courierQuerySnapshot = await FirebaseFirestore.instance
          .collection('couriers')
          .where('courier', isEqualTo: widget.courierName)
          .get();

      if (courierQuerySnapshot.docs.isNotEmpty) {
        final courierDocumentID = courierQuerySnapshot.docs.first.id;

        await FirebaseFirestore.instance
            .collection('couriers')
            .doc(courierDocumentID)
            .update({
          'courier': newCourierName,
        });

        // Update the userOrders subcollections where 'selectedCourier' matches the old courier name
        await FirebaseFirestore.instance
            .collectionGroup(
                'userOrders') // Use collectionGroup to query across all 'userOrders' subcollections
            .where('selectedCourier', isEqualTo: widget.courierName)
            .get()
            .then((querySnapshot) async {
          if (querySnapshot.docs.isNotEmpty) {
            for (final userOrderDoc in querySnapshot.docs) {
              final userOrderId = userOrderDoc.id;
              await userOrderDoc.reference.update({
                'selectedCourier': newCourierName,
              });
            }
          }
        });

        // Courier name updated successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Courier updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context, newCourierName);
      } else {
        // Courier with the original name not found in Firestore
        print('Courier not found in Firestore');
      }
    } catch (error) {
      // Handle any errors that occur during the update process
      print('Error updating Courier name: $error');

      // Show an error message or handle the error appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating Courier name.'),
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
                      final newCourierName = _newCourierController.text;
                      await _updateCourierName(newCourierName);
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
