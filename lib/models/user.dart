class User {
  final String userId;
  final String address;
  final String email;
  final String ic;
  final String imageUrl;
  final String
      password; // Note: It's generally better not to store passwords in plain text.
  final String phone;
  final String username;

  User({
    required this.userId,
    required this.address,
    required this.email,
    required this.ic,
    required this.imageUrl,
    required this.password,
    required this.phone,
    required this.username,
  });

  // A factory constructor to create a User instance from Firestore data
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User(
      userId: documentId,
      address: data['address'],
      email: data['email'],
      ic: data['ic'],
      imageUrl: data['image_url'],
      password: data['password'],
      phone: data['phone'],
      username: data['username'],
    );
  }
}
