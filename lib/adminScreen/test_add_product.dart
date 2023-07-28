import 'package:ecommerce/adminScreen/add_category.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/models/category.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TestAddProduct extends StatefulWidget {
  const TestAddProduct({Key? key}) : super(key: key);

  @override
  State<TestAddProduct> createState() => _TestAddProductState();
}

class _TestAddProductState extends State<TestAddProduct> {
  List<Category> _category = [];
  var _isLoading = true;
  String? _error;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  void _refreshCategory() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadCategory();
  }

  void _loadCategory() async {
    final url = Uri.https(
      'ecommerce-cb642-default-rtdb.firebaseio.com',
      'category-list.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<Category> loadedCategory = [];
      for (final item in listData.entries) {
        loadedCategory.add(
          Category(
            id: item.key,
            name: item.value['name'],
          ),
        );
      }
      setState(() {
        _category = loadedCategory;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong! Please try again later';
      });
    }
  }

  void _addCategory() async {
    final newItem = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (ctx) => AddCategory(refreshCallback: _refreshCategory),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _category.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget content = const Center(child: Text('No category yet.'));

    // if (_isLoading) {
    //   content = const Center(child: CircularProgressIndicator());
    // }

    // if (_category.isNotEmpty) {
    //   content = ListView.builder(
    //     itemCount: _category.length,
    //     itemBuilder: (ctx, index) => Dismissible(
    //       key: ValueKey(_category[index].id),
    //       child: ListTile(
    //         title: Text(_category[index].name),
    //         leading: Container(
    //           width: 24,
    //           height: 24,
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // if (_error != null) {
    //   content = Center(child: Text(_error!));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
        actions: [
          IconButton(
            onPressed: _addCategory,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Expanded(
          //   child: content,
          // ),
          if (_category
              .isNotEmpty) // Add this check to show the dropdown only when _category is not empty
            DropdownButtonFormField<Category>(
              value: _selectedCategory ??
                  _category.first, // Provide an initial value for the dropdown
              items: _category.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
        ],
      ),
    );
  }
}
