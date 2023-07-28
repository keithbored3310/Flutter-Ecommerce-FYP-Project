import 'package:ecommerce/adminScreen/add_brand.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/models/brand.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TestAddBrand extends StatefulWidget {
  const TestAddBrand({Key? key}) : super(key: key);

  @override
  State<TestAddBrand> createState() => _TestAddBrandState();
}

class _TestAddBrandState extends State<TestAddBrand> {
  List<Brand> _brand = [];
  var _isLoading = true;
  String? _error;
  Brand? _selectedBrand;

  @override
  void initState() {
    super.initState();
    _loadBrand();
  }

  void _refreshBrand() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadBrand();
  }

  void _loadBrand() async {
    final url = Uri.https(
      'ecommerce-cb642-default-rtdb.firebaseio.com',
      'brand-list.json',
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
      final List<Brand> loadedBrand = [];
      for (final item in listData.entries) {
        loadedBrand.add(
          Brand(
            id: item.key,
            brand: item.value['brand'],
          ),
        );
      }

      setState(() {
        _brand = loadedBrand;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
  }

  void _addBrand() async {
    final newItem = await Navigator.of(context).push<Brand>(
      MaterialPageRoute(
        builder: (ctx) => AddBrand(refreshCallback: _refreshBrand),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _brand.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand'),
        actions: [
          IconButton(
            onPressed: _addBrand,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Form(
        // Add the Form widget here
        child: Column(
          children: [
            if (_brand.isNotEmpty)
              DropdownButtonFormField<Brand>(
                value: _selectedBrand ?? _brand.first,
                items: _brand.map((brand) {
                  return DropdownMenuItem<Brand>(
                    value: brand,
                    child: Text(brand.brand),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
