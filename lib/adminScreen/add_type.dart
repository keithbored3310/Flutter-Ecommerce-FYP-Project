import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddType extends StatefulWidget {
  final VoidCallback refreshCallback;
  const AddType({required this.refreshCallback, Key? key}) : super(key: key);

  @override
  _AddTypeState createState() => _AddTypeState();
}

class _AddTypeState extends State<AddType> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTypeName = '';
  var _isSending = false;

  void _saveType() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        'ecommerce-cb642-default-rtdb.firebaseio.com',
        'type-list.json',
      );
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'type': _enteredTypeName,
      });

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // Successfully add product into database
        Navigator.pop(context);
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
          title: Text('Add Type'),
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
                        labelText: 'Type Name',
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
                          return 'Please enter a type name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredTypeName = value!;
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
                            onPressed: _saveType,
                            child: const Text('Add Brand'),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
