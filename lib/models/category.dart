import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String category;

  const Category({
    required this.id,
    required this.category,
  });

  factory Category.fromDocumentSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return Category(
      id: snapshot.id,
      category: data['category'],
    );
  }

  // Method to convert the Category object to a JSON representation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
    };
  }
}
