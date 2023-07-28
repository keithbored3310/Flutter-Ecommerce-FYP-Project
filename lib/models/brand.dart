class Brand {
  const Brand({
    required this.id,
    required this.brand,
  });

  final String id;
  final String brand;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
    };
  }

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      brand: json['brand'],
    );
  }
}
