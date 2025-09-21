class Category {
  final String id;   
  final String name; 

  Category({
    required this.id,
    required this.name,
  });

  // Untuk debugging / print object
  @override
  String toString() {
    return 'Category(id: $id, name: $name)';
  }
}
