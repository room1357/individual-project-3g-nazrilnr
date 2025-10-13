class Category {
  final String id;   
  final String name; 
  final String userId;

  Category({
    required this.id,
    required this.name,
    required this.userId,
  });

  // Untuk debugging / print object
  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}
