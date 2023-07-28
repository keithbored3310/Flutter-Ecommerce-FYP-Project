class Type {
  const Type({
    required this.id,
    required this.type,
  });

  final String id;
  final String type;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }

  factory Type.fromJson(Map<String, dynamic> json) {
    return Type(
      id: json['id'],
      type: json['type'],
    );
  }
}
