import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TypeDropdown extends StatefulWidget {
  const TypeDropdown({
    super.key,
    required this.onTypeChanged,
    required this.selectedType,
  });

  final String? selectedType;
  final ValueChanged<String?> onTypeChanged;

  @override
  State<TypeDropdown> createState() => _TypeDropdownState();
}

class _TypeDropdownState extends State<TypeDropdown> {
  String? _selectedType; // Nullable selected type

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType; // Set the initial value to null
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('types').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final types = snapshot.data!.docs;
          // Build the drop-down list using the data from Firestore
          return DropdownButtonFormField<String>(
            value: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
                widget.onTypeChanged(value);
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select Type'), // Default text
              ),
              ...types
                  .map((type) {
                    final typeName = type.data()['type'];
                    if (typeName != null) {
                      return DropdownMenuItem<String>(
                        value: typeName,
                        child: Text(typeName),
                      );
                    } else {
                      return null; // Return null for null typeName
                    }
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
            ],
            decoration: const InputDecoration(
              labelText: 'Type',
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
