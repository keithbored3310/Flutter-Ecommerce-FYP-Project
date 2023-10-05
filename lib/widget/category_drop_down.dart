import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDropdown extends StatefulWidget {
  const CategoryDropdown({
    super.key,
    required this.onCategoryChanged,
    required this.selectedCategory,
  });

  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('categories').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final categories = snapshot.data!.docs;
          return DropdownButtonFormField<String>(
            value: _selectedCategory,
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                widget.onCategoryChanged(value);
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Select Category'),
              ),
              ...categories
                  .map((category) {
                    final categoryName = category.data()['category'];
                    if (categoryName != null) {
                      return DropdownMenuItem<String>(
                        value: categoryName,
                        child: Text(categoryName),
                      );
                    } else {
                      return null;
                    }
                  })
                  .whereType<DropdownMenuItem<String>>()
                  .toList(),
            ],
            decoration: const InputDecoration(
              labelText: 'Category',
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
