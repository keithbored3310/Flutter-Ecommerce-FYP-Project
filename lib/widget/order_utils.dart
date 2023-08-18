import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteOldPendingOrders() async {
  // Calculate the timestamp for 5 hours ago
  final DateTime fiveHoursAgo =
      DateTime.now().subtract(const Duration(hours: 5));

  // Query for orders with status 1 and created_at timestamp before fiveHoursAgo
  QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: 1)
      .where('timestamp', isLessThan: fiveHoursAgo)
      .get();

  // Delete each old pending order and its associated userOrders
  for (QueryDocumentSnapshot orderDoc in ordersSnapshot.docs) {
    // Get the associated userOrders collection reference
    CollectionReference userOrdersCollection =
        orderDoc.reference.collection('userOrders');

    // Delete each userOrder document
    QuerySnapshot userOrdersSnapshot = await userOrdersCollection.get();
    for (QueryDocumentSnapshot userOrderDoc in userOrdersSnapshot.docs) {
      await userOrderDoc.reference.delete();
    }

    // Delete the order itself
    await orderDoc.reference.delete();
  }
}
