import 'package:ecommerce/adminScreen/edit_category.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/category.dart';
import 'package:ecommerce/adminScreen/add_category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _sortByAscending = true;

  void _showDeleteConfirmationDialog(String categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the delete operation and refresh the list of category
                _deleteCategory(categoryId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(String categoryId) {
    if (categoryId.isNotEmpty) {
      print('Deleting category with ID: $categoryId');
      FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .delete()
          .then((_) {
        // Category successfully deleted
        // You can add a snackbar or any other UI feedback here
        // After deleting, refresh the list of category
        setState(() {});
      }).catchError((error) {
        // Error occurred while deleting the category
        print('Error deleting category: $error');
      });
    } else {
      print('Invalid category ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Category'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddcategoryPage when the add icon button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCategoryPage(),
                ),
              ).then((_) {
                // Refresh the list of category when returning from the AddcategoryPage
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
            .collection('categories')
            .orderBy('category', descending: !_sortByAscending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final categories = snapshot.data!.docs
                .map((doc) => Category.fromDocumentSnapshot(
                    doc)) // Use fromDocumentSnapshot here
                .toList();

            if (categories.isEmpty) {
              // Show a message when there are no category available
              return const Center(
                child: Text(
                  'No categories available. Add a categories to get started!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCategoryPage(
                                  categoryName: category.category),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(category.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error fetching categories');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
