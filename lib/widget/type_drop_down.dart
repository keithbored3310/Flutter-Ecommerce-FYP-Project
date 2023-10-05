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
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('types').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final types = snapshot.data!.docs;
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
                child: Text('Select Type'),
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
                      return null;
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
