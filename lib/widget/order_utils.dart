import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteOldPendingOrders() async {
  final DateTime fiveHoursAgo =
      DateTime.now().subtract(const Duration(hours: 5));

  QuerySnapshot ordersSnapshot = await FirebaseFirestore.instance
      .collection('orders')
      .where('status', isEqualTo: 1)
      .where('timestamp', isLessThan: fiveHoursAgo)
      .get();

  for (QueryDocumentSnapshot orderDoc in ordersSnapshot.docs) {
    CollectionReference userOrdersCollection =
        orderDoc.reference.collection('userOrders');

    QuerySnapshot userOrdersSnapshot = await userOrdersCollection.get();
    for (QueryDocumentSnapshot userOrderDoc in userOrdersSnapshot.docs) {
      await userOrderDoc.reference.delete();
    }

    await orderDoc.reference.delete();
  }
}
