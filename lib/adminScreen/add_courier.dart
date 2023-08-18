import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCourierPage extends StatefulWidget {
  const AddCourierPage({super.key});

  @override
  State<AddCourierPage> createState() => _AddCourierPageState();
}

class _AddCourierPageState extends State<AddCourierPage> {
  final _formKey = GlobalKey<FormState>();
  final _courierController = TextEditingController();
  String? _errorMessage;
  bool _isAddingCourier = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Courier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _courierController,
                decoration: const InputDecoration(labelText: 'Courier Name'),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Please enter a courier name';
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
                    onPressed: _isAddingCourier ? null : _addCourier,
                    child: _isAddingCourier
                        ? const CircularProgressIndicator()
                        : const Text('Add Courier'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCourier() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isAddingCourier = true;
        _errorMessage = null;
      });

      // Form is valid, check if courier name already exists (case-insensitive)
      bool courierExists = await _checkCourierName(_courierController.text);
      if (courierExists) {
        setState(() {
          _errorMessage = 'Courier name already exists';
          _isAddingCourier = false;
        });
      } else {
        // Courier name is valid, add the courier to the Firestore collection
        addCourierToFirestore(_courierController.text);

        // Show a Snackbar to indicate successful courier addition
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Courier added successfully'),
            duration: Duration(seconds: 2),
          ),
        );

        // Wait for the Snackbar to disappear, then return to the previous page
        await Future.delayed(const Duration(seconds: 2));
        Navigator.pop(context);
      }
    }
  }

  Future<bool> _checkCourierName(String courierName) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('couriers')
        .where('courier', isEqualTo: courierName.toLowerCase())
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  void addCourierToFirestore(String courierName) async {
    // Get the next auto-incremented number
    int autoIncrementedNumber = await _getNextAutoIncrementNumber();

    // Add the courier with the auto-incremented number to the Firestore collection
    FirebaseFirestore.instance.collection('couriers').add({
      'id': autoIncrementedNumber,
      'courier': courierName,
    });
  }

  Future<int> _getNextAutoIncrementNumber() async {
    // Get the latest auto-incremented number from Firestore
    var latestNumberSnapshot = await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('couriers_counter')
        .get();

    int latestNumber = latestNumberSnapshot.exists
        ? latestNumberSnapshot.data()!['latest_number']
        : 0;

    // Increment the latest number and update it in Firestore
    int nextNumber = latestNumber + 1;
    await FirebaseFirestore.instance
        .collection('auto_increment')
        .doc('couriers_counter')
        .set({'latest_number': nextNumber});

    return nextNumber;
  }
}
