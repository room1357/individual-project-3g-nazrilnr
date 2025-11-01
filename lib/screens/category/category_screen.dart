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

  void _addCategory() {
    if (_controller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama kategori tidak boleh kosong')),
      );
      return;
    }
    
    final userId = AuthService().currentUser?.uid;
    if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kesalahan: Pengguna belum login.')),
        );
        return;
    }

    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _controller.text,
      userId: userId,
    );

    ExpenseService().addCategory(newCategory);
    _controller.clear();
    setState(() {});
  }

  void _removeCategory(String id) {
    ExpenseService().deleteCategory(id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final categories = ExpenseService().categories;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Input tambah kategori
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Tambah kategori baru',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: _addCategory,
                      tooltip: 'Tambah Kategori',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List kategori
            Expanded(
              child: categories.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada kategori',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 2),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade200,
                              child: Text(
                                category.name[0].toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeCategory(category.id),
                              tooltip: 'Hapus Kategori',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
