import 'package:ecommerce/adminScreen/add_courier.dart';
import 'package:ecommerce/adminScreen/edit_courier.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  State<CourierScreen> createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  bool _sortByAscending = true;

  void _showDeleteConfirmationDialog(String courierId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this courier?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform the delete operation and refresh the list of couriers
                _deleteCourier(courierId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourier(String courierId) {
    if (courierId.isNotEmpty) {
      print('Deleting courier with ID: $courierId');
      FirebaseFirestore.instance
          .collection('couriers')
          .doc(courierId)
          .delete()
          .then((_) {
        // Courier successfully deleted
        // You can add a snackbar or any other UI feedback here
        // After deleting, refresh the list of couriers
        setState(() {});
      }).catchError((error) {
        // Error occurred while deleting the courier
        print('Error deleting courier: $error');
      });
    } else {
      print('Invalid courier ID');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Couriers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to the AddBrandPage when the add icon button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCourierPage(),
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
            .collection('couriers')
            .orderBy('courier', descending: !_sortByAscending)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final couriers = snapshot.data!.docs;

            if (couriers.isEmpty) {
              // Show a message when there are no couriers available
              return const Center(
                child: Text(
                  'No couriers available.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              itemCount: couriers.length,
              itemBuilder: (context, index) {
                final courier = couriers[index];
                return ListTile(
                  title: Text(courier['courier']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCourierPage(
                                  courierName: courier.data()[
                                      'courier']), // Retrieve 'courier' field using .data()
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(courier.id);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Text('Error fetching couriers');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
