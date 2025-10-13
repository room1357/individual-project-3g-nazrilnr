class Category {
  final String id;
  final String name; 
  final String userId; // Untuk Kategori Per Pengguna

  Category({
    required this.id,
    required this.name,
    required this.userId,
  });

  // --- JSON DESERIALIZATION (Dari Map JSON ke Objek Dart) ---
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
    );
  }

  // --- JSON SERIALIZATION (Dari Objek Dart ke Map JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
    };
  }
}