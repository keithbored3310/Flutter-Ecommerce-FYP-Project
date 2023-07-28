import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddBrand extends StatefulWidget {
  final VoidCallback refreshCallback;
  const AddBrand({required this.refreshCallback, Key? key}) : super(key: key);

  @override
  _AddBrandState createState() => _AddBrandState();
}

class _AddBrandState extends State<AddBrand> {
  final _formKey = GlobalKey<FormState>();
  var _enteredBrandName = '';
  var _isSending = false;

  void _saveBrand() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        'ecommerce-cb642-default-rtdb.firebaseio.com',
        'brand-list.json',
      );
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'brand': _enteredBrandName,
      });

      final response = await http.post(url, headers: headers, body: body);

      final currentContext = context;
      if (response.statusCode == 200) {
        // Successfully add product into database
        Navigator.pop(currentContext);
        widget.refreshCallback(); // Trigger refresh callback
      } else {
        // Failed
      }

      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Brand'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Brand Name',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z ]+$'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'Please enter a brand name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredBrandName = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveBrand,
                          child: const Text('Add Brand'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
