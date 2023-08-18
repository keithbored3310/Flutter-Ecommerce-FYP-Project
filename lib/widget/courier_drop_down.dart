import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourierDropdown extends StatefulWidget {
  const CourierDropdown({
    super.key,
    required this.onCourierChanged,
    required this.selectedCourier,
  });

  final String? selectedCourier;
  final ValueChanged<String?> onCourierChanged;

  @override
  State<CourierDropdown> createState() => _CourierDropdownState();
}

class _CourierDropdownState extends State<CourierDropdown> {
  String? _selectedCourier; // Nullable selected courier

  @override
  void initState() {
    super.initState();
    _selectedCourier = widget.selectedCourier; // Set the initial value
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('couriers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final couriers = snapshot.data!.docs;
          // Build the drop-down list using the data from Firestore
          return DropdownButtonFormField<String>(
            value: _selectedCourier,
            onChanged: (value) {
              setState(() {
                _selectedCourier = value;
                widget.onCourierChanged(value);
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select Courier'), // Default text
              ),
              ...couriers
                  .map((courier) {
                    final courierName = courier.data()['courier'];
                    if (courierName != null) {
                      return DropdownMenuItem<String>(
                        value: courierName,
                        child: Text(courierName),
                      );
                    } else {
                      return null; // Return null for null courierName
                    }
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
            ],
            decoration: const InputDecoration(
              labelText: 'Courier',
              border: OutlineInputBorder(),
            ),
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
