import 'package:flutter/material.dart';
import 'package:ecommerce/widget/brand_drop_down.dart';
import 'package:ecommerce/widget/category_drop_down.dart';
import 'package:ecommerce/widget/type_drop_down.dart';

class FilterDialog extends StatefulWidget {
  final FilterOptions initialFilterOptions;
  final String? selectedBrand;
  final String? selectedCategory;
  final String? selectedType;
  final void Function(FilterOptions options, String? newBrand,
      String? newCategory, String? newType) onApply;
  final VoidCallback onClear; // Add this line

  FilterDialog({
    required this.initialFilterOptions,
    required this.selectedBrand,
    required this.selectedCategory,
    required this.selectedType,
    required this.onApply,
    required this.onClear, // Add this line
  });

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions filterOptions; // Declare filterOptions here
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterOptions = widget.initialFilterOptions; // Initialize filterOptions
    if (filterOptions.minPrice != null) {
      minPriceController.text = filterOptions.minPrice.toString();
    }
    if (filterOptions.maxPrice != null) {
      maxPriceController.text = filterOptions.maxPrice.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Products'),
      content: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CheckboxListTile(
                    title: const Text('Sort A-Z'),
                    value: filterOptions.sortAscending,
                    onChanged: (value) {
                      setState(() {
                        filterOptions.sortAscending = value ?? false;
                        if (value == true) {
                          filterOptions.sortDescending = false;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Sort Z-A'),
                    value: filterOptions.sortDescending,
                    onChanged: (value) {
                      setState(() {
                        filterOptions.sortDescending = value ?? false;
                        if (value == true) {
                          filterOptions.sortAscending = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Price',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  RadioListTile(
                    title: const Text('Sort Ascending'),
                    value: true,
                    groupValue: filterOptions.sortPriceAscending,
                    onChanged: (value) {
                      setState(() {
                        filterOptions.sortPriceAscending = value as bool;
                        filterOptions.sortPriceDescending = !value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: const Text('Sort Descending'),
                    value: true,
                    groupValue: filterOptions.sortPriceDescending,
                    onChanged: (value) {
                      setState(() {
                        filterOptions.sortPriceDescending = value as bool;
                        filterOptions.sortPriceAscending = !value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Price Range',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Min Price'),
                          onChanged: (value) {
                            setState(() {
                              filterOptions.minPrice =
                                  value.isEmpty ? null : double.parse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Max Price'),
                          onChanged: (value) {
                            setState(() {
                              filterOptions.maxPrice =
                                  value.isEmpty ? null : double.parse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Add the BrandDropdown widget
                  BrandDropdown(
                    selectedBrand: filterOptions
                        .selectedBrand, // Use filterOptions.selectedBrand
                    onBrandChanged: (value) {
                      setState(() {
                        filterOptions.selectedBrand =
                            value; // Update selectedBrand in filterOptions
                        print("selectedBrand: ${filterOptions.selectedBrand}");
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CategoryDropdown(
                    selectedCategory: filterOptions
                        .selectedCategory, // Use filterOptions.selectedBrand
                    onCategoryChanged: (value) {
                      setState(() {
                        filterOptions.selectedCategory =
                            value; // Update selectedBrand in filterOptions
                        print(
                            "selectedCategory: ${filterOptions.selectedCategory}");
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TypeDropdown(
                    selectedType: filterOptions
                        .selectedType, // Use filterOptions.selectedBrand
                    onTypeChanged: (value) {
                      setState(() {
                        filterOptions.selectedType =
                            value; // Update selectedBrand in filterOptions
                        print("selectedType: ${filterOptions.selectedType}");
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    filterOptions = FilterOptions(); // Clear all filter options
                    filterOptions.selectedBrand =
                        null; // Clear the selected brand
                    filterOptions.selectedCategory = null;
                    filterOptions.selectedType = null;
                    minPriceController.clear();
                    maxPriceController.clear();
                  });
                  widget.onClear(); // Notify parent that filters are cleared
                  Navigator.of(context).pop(); // Pop the dialog screen
                },
                child: const Text('Clear'),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onApply(
                      filterOptions,
                      filterOptions.selectedBrand,
                      filterOptions.selectedCategory,
                      filterOptions.selectedType);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FilterOptions {
  bool sortAscending = false;
  bool sortDescending = false;
  bool sortPriceAscending = false;
  bool sortPriceDescending = false;
  double? minPrice;
  double? maxPrice;
  String? selectedBrand; // New field for selected brand
  String? selectedCategory; // New field for selected category
  String? selectedType; // New field for selected type
}
