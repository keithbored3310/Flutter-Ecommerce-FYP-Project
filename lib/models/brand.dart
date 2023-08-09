import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  String id;
  String brand;

  Brand({
    required this.id,
    required this.brand,
  });

  factory Brand.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Brand(
      id: snapshot.id,
      brand: data['brand'],
    );
  }

  // Method to convert the Brand object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
    };
  }
}
