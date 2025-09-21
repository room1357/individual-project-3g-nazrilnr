import '../models/category.dart';

class CategoryManager {
  // Daftar kategori default
  static List<Category> categories = [
    Category(id: '1', name: 'Makanan'),
    Category(id: '2', name: 'Transportasi'),
    Category(id: '3', name: 'Utilitas'),
    Category(id: '4', name: 'Hiburan'),
    Category(id: '5', name: 'Pendidikan'),
  ];

  // Tambah kategori baru
  static void addCategory(Category category) {
    categories.add(category);
  }

  // Hapus kategori berdasarkan id
  static void removeCategory(String id) {
    categories.removeWhere((category) => category.id == id);
  }

  // Cari kategori berdasarkan id
  static Category? findCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Cari kategori berdasarkan nama
  static Category? findCategoryByName(String name) {
    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Update kategori
  static void updateCategory(String id, String newName) {
    final index = categories.indexWhere((category) => category.id == id);
    if (index != -1) {
      categories[index] = Category(id: id, name: newName);
    }
  }
}