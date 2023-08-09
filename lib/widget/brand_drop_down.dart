import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BrandDropdown extends StatefulWidget {
  const BrandDropdown({
    super.key,
    required this.onBrandChanged,
    required this.selectedBrand,
  });

  final String? selectedBrand;
  final ValueChanged<String?> onBrandChanged;

  @override
  _BrandDropdownState createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  String? _selectedBrand; // Nullable selected brand

  @override
  void initState() {
    super.initState();
    // Initialize the selected brand with the provided value from the constructor
    _selectedBrand = widget.selectedBrand;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('brands').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final brands = snapshot.data!.docs;
          // Build the drop-down list using the data from Firestore
          return DropdownButtonFormField<String>(
            value: _selectedBrand,
            onChanged: (value) {
              setState(() {
                _selectedBrand = value;
                widget.onBrandChanged(value);
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null, // Set 'Other' as the default value
                child: Text('Select Brand'), // Default text
              ),
              ...brands
                  .map((brand) {
                    final brandName = brand.data()['brand'];
                    if (brandName != null) {
                      return DropdownMenuItem<String>(
                        value: brandName,
                        child: Text(brandName),
                      );
                    } else {
                      return null; // Return null for null brandName
                    }
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
            ],
            decoration: const InputDecoration(
              labelText: 'Brand',
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
