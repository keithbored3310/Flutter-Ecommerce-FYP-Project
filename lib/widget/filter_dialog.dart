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
  final VoidCallback onClear;

  const FilterDialog({
    super.key,
    required this.initialFilterOptions,
    required this.selectedBrand,
    required this.selectedCategory,
    required this.selectedType,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late FilterOptions filterOptions;
  TextEditingController minPriceController = TextEditingController();
  TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filterOptions = widget.initialFilterOptions;
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
                  const Text('Price',
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
                  const Text('Price Range',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: minPriceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(labelText: 'Min Price'),
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
                          decoration:
                              const InputDecoration(labelText: 'Max Price'),
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
                  BrandDropdown(
                    selectedBrand: filterOptions.selectedBrand,
                    onBrandChanged: (value) {
                      setState(() {
                        filterOptions.selectedBrand = value;
                        // print("selectedBrand: ${filterOptions.selectedBrand}");
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CategoryDropdown(
                    selectedCategory: filterOptions.selectedCategory,
                    onCategoryChanged: (value) {
                      setState(() {
                        filterOptions.selectedCategory = value;
                        // print(
                        // "selectedCategory: ${filterOptions.selectedCategory}");
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TypeDropdown(
                    selectedType: filterOptions.selectedType,
                    onTypeChanged: (value) {
                      setState(() {
                        filterOptions.selectedType = value;
                        // print("selectedType: ${filterOptions.selectedType}");
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
                    filterOptions = FilterOptions();
                    filterOptions.selectedBrand = null;
                    filterOptions.selectedCategory = null;
                    filterOptions.selectedType = null;
                    minPriceController.clear();
                    maxPriceController.clear();
                  });
                  widget.onClear();
                  Navigator.of(context).pop();
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
  String? selectedBrand;
  String? selectedCategory;
  String? selectedType;
}
