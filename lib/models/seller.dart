class Seller {
  final String sellerId;
  final String companyName;
  final String registrationNumber;
  final String shopName;
  final String pickupAddress;
  final String email;
  final String phoneNumber;
  final String imageUrl;

  Seller({
    required this.sellerId,
    required this.companyName,
    required this.registrationNumber,
    required this.shopName,
    required this.pickupAddress,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
  });

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      sellerId: map['sellerId'] as String,
      companyName: map['companyName'] as String,
      registrationNumber: map['registrationNumber'] as String,
      shopName: map['shopName'] as String,
      pickupAddress: map['pickupAddress'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }
}
