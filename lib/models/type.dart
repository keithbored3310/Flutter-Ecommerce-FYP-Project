import 'package:cloud_firestore/cloud_firestore.dart';

class Type {
  String id;
  String type;

  Type({
    required this.id,
    required this.type,
  });

  factory Type.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Type(
      id: snapshot.id,
      type: data['type'],
    );
  }

  // Method to convert the Type object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}
