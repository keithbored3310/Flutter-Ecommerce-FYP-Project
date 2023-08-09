class Product {
  final String id;
  final List<Map<String, dynamic>> brand;
  final List<Map<String, dynamic>> category;
  final double discount;
  final double discountedPrice;
  final String name;
  final String description;
  final int partNumber;
  final double price;
  final int quantity;
  final List<Map<String, dynamic>> type;

  Product({
    required this.id,
    required this.brand,
    required this.category,
    required this.discount,
    required this.discountedPrice,
    required this.name,
    required this.description,
    required this.partNumber,
    required this.price,
    required this.quantity,
    required this.type,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      brand: List<Map<String, dynamic>>.from(json['brand']),
      category: List<Map<String, dynamic>>.from(json['category']),
      discount: json['discount'],
      discountedPrice: json['discountedPrice'],
      name: json['name'],
      description: json['description'],
      partNumber: json['partNumber'],
      price: json['price'],
      quantity: json['quantity'],
      type: List<Map<String, dynamic>>.from(json['type']),
    );
  }
}
