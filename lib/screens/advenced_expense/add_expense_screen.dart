import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import 'package:uuid/uuid.dart';
import '../../service/expense_service.dart'; // Import service untuk manajemen data

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Key global untuk validasi formulir
  final _formKey = GlobalKey<FormState>();
  // Controllers untuk mengambil input teks dari pengguna
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variabel untuk menyimpan kategori dan tanggal yang dipilih
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Mengambil daftar kategori dari ExpenseService saat layar dimuat
    final categories = ExpenseService().categories;
    // Mengatur kategori pertama sebagai nilai default jika ada
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  // Metode untuk menampilkan dialog pemilih tanggal (date picker)
  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    // Memperbarui tanggal yang dipilih jika pengguna memilih tanggal
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Metode untuk menyimpan pengeluaran baru setelah validasi
  void _saveExpense() {
    // Memastikan semua field formulir valid
    if (_formKey.currentState!.validate()) {
      // Membuat objek Expense baru dari input pengguna
      final newExpense = Expense(
        id: const Uuid().v4(), // Menggunakan Uuid untuk ID unik
        title: _titleController.text,
        amount: double.parse(_amountController.text), // Mengonversi string ke double
        category: _selectedCategory!.name,
        date: _selectedDate,
        description: _descriptionController.text,
      );

      // Memanggil ExpenseService untuk menyimpan pengeluaran
      ExpenseService().addExpense(newExpense);
      // Kembali ke layar sebelumnya
      Navigator.pop(context);
    }
  }

  // Metode helper untuk styling input field yang konsisten
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
    Widget build(BuildContext context) {
    // Mengambil daftar kategori dari service untuk dropdown
    final categories = ExpenseService().categories;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Tambah Pengeluaran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Judul'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan judul' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: _inputDecoration('Jumlah'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan jumlah';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem<Category>( // Perbaikan di sini
                          value: cat,
                          child: Text(cat.name),
                        ))
                    .toList(),
                onChanged: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                },
                decoration: _inputDecoration('Kategori'),
                validator: (value) =>
                    value == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}