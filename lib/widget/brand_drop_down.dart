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
  State<BrandDropdown> createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  String? _selectedBrand;
  @override
  void initState() {
    super.initState();
    _selectedBrand = widget.selectedBrand;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('brands').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final brands = snapshot.data!.docs;
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
                value: null,
                child: Text('Select Brand'),
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
                      return null;
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
