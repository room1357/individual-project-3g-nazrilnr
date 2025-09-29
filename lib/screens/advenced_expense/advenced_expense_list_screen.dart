import 'package:flutter/material.dart' hide DateUtils;
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../service/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  // Future yang mengelola status pemuatan data awal
  Future<void>? _dataFuture;
  // Variabel untuk melacak kategori yang dipilih saat ini
  String selectedCategory = 'Semua';
  // Controller untuk mengelola input pada kolom pencarian
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Memulai pemuatan data saat widget pertama kali dibuat
    _dataFuture = _loadInitialData();
  }

  // Metode asinkron untuk memuat data awal dari service
  Future<void> _loadInitialData() async {
    // Memanggil ExpenseService untuk memuat data dari penyimpanan
    await ExpenseService().loadInitialData();
    // Memicu rebuild UI setelah data berhasil dimuat
    setState(() {});
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Pengeluaran Advanced',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          // Menampilkan indikator loading saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Menampilkan pesan error jika ada masalah saat memuat data
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          // Mengambil data pengeluaran dan kategori dari ExpenseService
          final expenses = ExpenseService().expenses;
          final categories = ExpenseService().categories;

          // Logika untuk memfilter pengeluaran berdasarkan pencarian dan kategori
          final filteredExpenses = expenses.where((expense) {
            bool matchesSearch = searchController.text.isEmpty ||
                expense.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
                expense.description.toLowerCase().contains(searchController.text.toLowerCase());
            bool matchesCategory =
                selectedCategory == 'Semua' || expense.category == selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom pencarian pengeluaran
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Cari pengeluaran...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // Daftar chip kategori yang bisa di-scroll
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      ..._buildCategoryChips(categories),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Kartu statistik (Total, Jumlah, Rata-rata)
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        label: 'Total',
                        value: CurrencyUtils.formatCurrency(_calculateFilteredTotal(filteredExpenses)),
                        colors: [Colors.green.shade400, Colors.green.shade200],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        label: 'Jumlah',
                        value: '${filteredExpenses.length} item',
                        colors: [Colors.blue.shade400, Colors.blue.shade200],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        label: 'Rata-rata',
                        value: CurrencyUtils.formatCurrency(_calculateAverage(filteredExpenses)),
                        colors: [Colors.orange.shade400, Colors.orange.shade200],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Judul "Daftar Pengeluaran"
                const Text(
                  "Daftar Pengeluaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Tampilan daftar pengeluaran atau pesan jika kosong
                if (filteredExpenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Tidak ada pengeluaran ditemukan'),
                    ),
                  )
                else
                  ...filteredExpenses.map((expense) => _buildExpenseListItem(context, expense)).toList(),
              ],
            ),
          );
        },
      ),
      // Tombol tambah pengeluaran baru
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke layar tambah, lalu muat ulang data saat kembali
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _loadInitialData();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Widget helper untuk membuat chip kategori
  List<Widget> _buildCategoryChips(List<Category> categories) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: const Text('Semua'),
          selected: selectedCategory == 'Semua',
          onSelected: (selected) {
            setState(() {
              selectedCategory = 'Semua';
            });
          },
        ),
      ),
      ...categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: selectedCategory == category.name,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category.name;
                });
              },
            ),
          )),
    ];
  }

  // Widget helper untuk membuat kartu statistik
  Widget _buildStatCard({
    required String label,
    required String value,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(2, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghitung rata-rata pengeluaran yang difilter
  double _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    double average = expenses.fold(0.0, (sum, expense) => sum + expense.amount) / expenses.length;
    return average;
  }

  // Fungsi untuk menghitung total pengeluaran yang difilter
  double _calculateFilteredTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Fungsi untuk mendapatkan warna berdasarkan kategori
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan': return Colors.orange;
      case 'transportasi': return Colors.green;
      case 'utilitas': return Colors.purple;
      case 'hiburan': return Colors.pink;
      case 'pendidikan': return Colors.blue;
      default: return Colors.grey;
    }
  }

  // Fungsi untuk mendapatkan ikon berdasarkan kategori
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan': return Icons.restaurant;
      case 'transportasi': return Icons.directions_car;
      case 'utilitas': return Icons.home;
      case 'hiburan': return Icons.movie;
      case 'pendidikan': return Icons.school;
      default: return Icons.attach_money;
    }
  }

  // Widget helper untuk membuat item daftar pengeluaran
  Widget _buildExpenseListItem(BuildContext context, Expense expense) {
    return InkWell(
      onTap: () => _showExpenseDetails(context, expense),
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
            CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category),
              child: Icon(_getCategoryIcon(expense.category), color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expense.category} • ${DateUtils.formatDate(expense.date)}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Text(
              CurrencyUtils.formatCurrency(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk menampilkan detail pengeluaran
  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Jumlah', CurrencyUtils.formatCurrency(expense.amount), Colors.blue),
            _buildDetailRow('Kategori', expense.category, Colors.green),
            _buildDetailRow('Tanggal', DateUtils.formatDate(expense.date), Colors.orange),
            _buildDetailRow('Deskripsi', expense.description, Colors.purple),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: const Text('Tutup'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditExpenseScreen(expense: expense)),
              );
              _loadInitialData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text('Hapus Pengeluaran'),
                  content: const Text(
                      'Apakah kamu yakin ingin menghapus pengeluaran ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        ExpenseService().deleteExpense(expense.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        _loadInitialData();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  // Widget helper untuk membuat baris detail di dialog
  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}