import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../service/expense_service.dart';
import '../../service/auth_service.dart'; 

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _controller = TextEditingController();

  // Metode untuk menambahkan kategori baru
  void _addCategory() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
      );
      return;
    }
    
    // Dapatkan ID pengguna yang sedang login (ownerId)
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kesalahan: Pengguna belum login.')),
        );
        return;
    }

    // Membuat objek Category baru dengan tagging userId
    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // id unik
      name: _controller.text,
      userId: userId, // <<< PERBAIKAN KRUSIAL: Tagging dengan User ID
    );

    // Memanggil ExpenseService untuk menambah kategori
    ExpenseService().addCategory(newCategory);

    _controller.clear();
    // setState() diperlukan untuk memperbarui UI setelah penambahan
    setState(() {}); 
  }

  // Metode untuk menghapus kategori
  void _removeCategory(String id) {
    // Memanggil ExpenseService untuk menghapus kategori
    ExpenseService().deleteCategory(id);
    // setState() diperlukan untuk memperbarui UI setelah penghapusan
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Ambil daftar kategori dari ExpenseService (Sudah difilter berdasarkan User ID di service)
    final categories = ExpenseService().categories;

    return Scaffold(
      body: Column(
        children: [
          // Input tambah kategori dalam wadah seperti kartu
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  // Kolom input untuk nama kategori baru
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nama kategori baru',
                      border: InputBorder.none, 
                    ),
                  ),
                ),
                // Tombol tambah
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: _addCategory,
                ),
              ],
            ),
          ),
          // List kategori
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Nama Kategori
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeCategory(category.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}