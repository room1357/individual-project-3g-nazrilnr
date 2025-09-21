import 'package:flutter/material.dart';
import '../managers/category_manager.dart';
import '../models/category.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  // Controller untuk input kategori baru
  final TextEditingController _controller = TextEditingController();

  void _addCategory() {
    if (_controller.text.isEmpty) return;

    final newCategory = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // id unik
      name: _controller.text,
    );

    setState(() {
      CategoryManager.addCategory(newCategory);
    });

    _controller.clear();
  }

  void _removeCategory(String id) {
    setState(() {
      CategoryManager.removeCategory(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = CategoryManager.categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kategori'),
      ),
      body: Column(
        children: [
          // Input tambah kategori
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nama kategori baru',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addCategory,
                )
              ],
            ),
          ),
          const Divider(),
          // List kategori
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeCategory(category.id),
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
