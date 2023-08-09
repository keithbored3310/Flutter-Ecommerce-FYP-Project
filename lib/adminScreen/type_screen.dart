import 'package:ecommerce/adminScreen/edit_type.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerce/models/type.dart';
import 'package:ecommerce/adminScreen/add_type.dart';

class TypeScreen extends StatefulWidget {
  const TypeScreen({super.key});

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  bool _sortByAscending = true;

  void _showDeleteConfirmationDialog(String typeId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this type?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the delete operation and refresh the list of types
                _deleteType(typeId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteType(String typeId) {
    print(typeId);
    if (typeId.isNotEmpty) {
      print('Deleting type with ID: $typeId');
      FirebaseFirestore.instance
          .collection('types')
          .doc(typeId)
          .delete()
          .then((_) {
        // Type successfully deleted
        // You can add a snackbar or any other UI feedback here
        // After deleting, refresh the list of types
        setState(() {});
      }).catchError((error) {
        // Error occurred while deleting the type
        print('Error deleting type: $error');
      });
    } else {
      print('Invalid type ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Types'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddTypePage when the add icon button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTypePage(),
                ),
              ).then((_) {
                // Refresh the list of types when returning from the AddTypePage
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
            .collection('types')
            .orderBy('type', descending: !_sortByAscending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final types = snapshot.data!.docs
                .map((doc) => Type.fromDocumentSnapshot(
                    doc)) // Use fromDocumentSnapshot here
                .toList();

            if (types.isEmpty) {
              // Show a message when there are no types available
              return const Center(
                child: Text(
                  'No types available. Add a type to get started!',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                return ListTile(
                  title: Text(type.type),
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
                                  EditTypePage(typeName: type.type),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(type.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error fetching types');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
