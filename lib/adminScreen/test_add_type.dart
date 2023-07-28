import 'package:ecommerce/adminScreen/add_type.dart';
import 'package:http/http.dart' as http;
import 'package:ecommerce/models/type.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class TestAddType extends StatefulWidget {
  const TestAddType({Key? key}) : super(key: key);

  @override
  State<TestAddType> createState() => _TestAddTypeState();
}

class _TestAddTypeState extends State<TestAddType> {
  List<Type> _type = [];
  var _isLoading = true;
  String? _error;
  Type? _selectedType;

  @override
  void initState() {
    super.initState();
    _loadType();
  }

  void _refreshType() {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    _loadType();
  }

  void _loadType() async {
    final url = Uri.https(
      'ecommerce-cb642-default-rtdb.firebaseio.com',
      'type-list.json',
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
      final List<Type> loadedType = [];
      for (final item in listData.entries) {
        loadedType.add(
          Type(
            id: item.key,
            type: item.value['type'],
          ),
        );
      }

      setState(() {
        _type = loadedType;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
      });
    }
  }

  void _addType() async {
    final newItem = await Navigator.of(context).push<Type>(
      MaterialPageRoute(
        builder: (ctx) => AddType(refreshCallback: _refreshType),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _type.add(newItem);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Type'),
        actions: [
          IconButton(
            onPressed: _addType,
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Text(_error!),
                )
              : ListView.builder(
                  itemCount: _type.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(_type[index].type),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addType,
        child: Icon(Icons.add),
      ),
    );
  }
}
