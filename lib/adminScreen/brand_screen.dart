import 'package:ecommerce/adminScreen/edit_brand.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/brand.dart';
import 'package:ecommerce/adminScreen/add_brand.dart';

class BrandScreen extends StatefulWidget {
  const BrandScreen({super.key});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  bool _sortByAscending = true;

  void _showDeleteConfirmationDialog(String brandId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this brand?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the delete operation and refresh the list of brands
                _deleteBrand(brandId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBrand(String brandId) {
    if (brandId.isNotEmpty) {
      print('Deleting brand with ID: $brandId');
      FirebaseFirestore.instance
          .collection('brands')
          .doc(brandId)
          .delete()
          .then((_) {
        // Brand successfully deleted
        // You can add a snackbar or any other UI feedback here
        // After deleting, refresh the list of brands
        setState(() {});
      }).catchError((error) {
        // Error occurred while deleting the brand
        print('Error deleting brand: $error');
      });
    } else {
      print('Invalid brand ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddBrandPage when the add icon button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddBrandPage(),
                ),
              ).then((_) {
                // Refresh the list of brands when returning from the AddBrandPage
                setState(() {});
              });
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                _sortByAscending = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: true,
                child: Text('Sort A-Z'),
              ),
              const PopupMenuItem(
                value: false,
                child: Text('Sort Z-A'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('brands')
            .orderBy('brand', descending: !_sortByAscending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final brands = snapshot.data!.docs
                .map((doc) => Brand.fromDocumentSnapshot(
                    doc)) // Use fromDocumentSnapshot here
                .toList();

            if (brands.isEmpty) {
              // Show a message when there are no brands available
              return const Center(
                child: Text(
                  'No brands available. Add a brand to get started!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                final brand = brands[index];
                return ListTile(
                  title: Text(brand.brand),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditBrandPage(brandName: brand.brand),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(brand.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error fetching brands');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
