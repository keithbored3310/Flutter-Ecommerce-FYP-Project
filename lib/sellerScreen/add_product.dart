import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/models/brand.dart';
import 'package:ecommerce/models/type.dart';

class AddProduct extends StatefulWidget {
  final VoidCallback refreshCallback;
  const AddProduct({required this.refreshCallback, Key? key}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  List<Category> _category = [];
  List<Brand> _brand = [];
  List<Type> _type = [];
  var _enteredProductName = '';
  Category? _selectedCategory;
  Brand? _selectedBrand;
  Type? _selectedType;
  var _enteredPrice = 0.0;
  var _enteredDiscount = 0.0;
  var _enteredDiscountPrice = 0.0;
  var _calculatedDiscountPrice = 0.0;
  var _enteredQuantity = 1;
  var _enteredPartNumber = '';
  var _isSending = false;
  File? _imageFile;
  var _isLoading = true;
  String? _error;

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _discountedPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCategory();
    _loadBrand();
    _loadType();
    _priceController.addListener(_updatePrice);
    _discountController.addListener(_updateDiscount);
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

  void _updatePrice() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    setState(() {
      _enteredPrice = price;
      _calculateDiscountPrice();
    });
  }

  void _updateDiscount() {
    final discountPercentage = double.tryParse(_discountController.text) ?? 0.0;
    setState(() {
      _enteredDiscount = discountPercentage;
      _calculateDiscountPrice();
    });
  }

  void _calculateDiscountPrice() {
    final discountPrice = _enteredPrice * (1 - (_enteredDiscount / 100));
    setState(() {
      _calculatedDiscountPrice = discountPrice;
      _enteredDiscountPrice = _calculatedDiscountPrice;
      _discountedPriceController.text =
          _enteredDiscountPrice.toStringAsFixed(2);
    });
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      // Upload image to Firebase Storage
      String imageUrl = '';
      if (_imageFile != null) {
        final storageRef = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

        final uploadTask = storageRef.putFile(_imageFile!);
        final snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      final url = Uri.https(
          'ecommerce-cb642-default-rtdb.firebaseio.com', 'product-list.json');

      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'name': _enteredProductName,
        'category': _selectedCategory
            ?.toJson(), // Convert the selected category to a JSON object
        'brand': _selectedBrand
            ?.toJson(), // Convert the selected brand to a JSON object
        'type': _selectedType
            ?.toJson(), // Convert the selected type to a JSON object
        'price': _enteredPrice.toString(),
        'discount': _enteredDiscount.toString(),
        'discountedPrice': _enteredDiscountPrice.toString(),
        'quantity': _enteredQuantity.toString(),
        'partNumber': _enteredPartNumber,
      });

      final response = await http.post(url, headers: headers, body: body);

      final BuildContext currentContext = context;
      if (response.statusCode == 200) {
        // Successfully add product into database
        Navigator.pop(currentContext);
        widget.refreshCallback();
      } else {
        // Failed to add product into database
      }

      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product Page'),
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
                    labelText: 'Product Name',
                  ),
                  keyboardType:
                      TextInputType.text, // Allow alphanumeric characters
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be between 1 and 50 characters';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredProductName = value!;
                  },
                ),
                const SizedBox(height: 12),
                if (_category
                    .isNotEmpty) // Add this check to show the dropdown only when _category is not empty
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory ??
                        _category
                            .first, // Provide an initial value for the dropdown
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
                const SizedBox(height: 12),
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
                const SizedBox(height: 12),
                if (_type.isNotEmpty)
                  DropdownButtonFormField<Type>(
                    value: _selectedType ?? _type.first,
                    items: _type.map((type) {
                      return DropdownMenuItem<Type>(
                        value: type,
                        child: Text(type.type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Select Image'),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 100),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Price (RM)',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _priceController,
                  onChanged: (_) => _updatePrice(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Discount Value (%)',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: _discountController,
                  onChanged: (_) => _updateDiscount(),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Discounted Price (RM)',
                  ),
                  controller: _discountedPriceController,
                  enabled: false,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _enteredQuantity.toString(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.tryParse(value)! <= 0) {
                      return 'Must be a valid, positive number.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredQuantity = int.parse(value!);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Part Number',
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: _enteredPartNumber.toString(),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        int.tryParse(value) == null ||
                        int.tryParse(value)! <= 0) {
                      return 'Must be a valid, positive number.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredPartNumber = value!;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.refreshCallback();
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveProduct,
                        child: const Text('Add Product'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
