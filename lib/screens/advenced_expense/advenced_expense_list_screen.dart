import 'package:flutter/material.dart' hide DateUtils;
import '../../models/expense.dart';
import '../../models/category.dart';
import '../../service/expense_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';
import '../../service/auth_service.dart'; 
import '../../service/shared_expense_service.dart'; 
import '../../screens/shared_expense/shared_proses_expense.dart';

class AdvancedExpenseListScreen extends StatefulWidget {
  const AdvancedExpenseListScreen({super.key});

  @override
  _AdvancedExpenseListScreenState createState() =>
      _AdvancedExpenseListScreenState();
}

class _AdvancedExpenseListScreenState extends State<AdvancedExpenseListScreen> {
  Future<void>? _dataFuture;
  String selectedCategory = 'Semua';
  TextEditingController searchController = TextEditingController();
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();

    // --- Listener ExpenseService untuk auto rebuild ---
    ExpenseService().addListener(_onExpenseServiceUpdated);
  }

  void _onExpenseServiceUpdated() {
    if (mounted) setState(() {}); // rebuild ketika service notifyListeners
  }

  Future<void> _loadInitialData() async {
    await ExpenseService().loadInitialData();
    if (mounted) setState(() {});
  }

  void _triggerFilter() {
    setState(() {
      selectedCategory = searchController.text.isEmpty ? 'Semua' : selectedCategory;
      _hasInteracted = true;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    ExpenseService().removeListener(_onExpenseServiceUpdated);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ExpenseService().expenses;
    final categories = ExpenseService().categories;

    final bool hasActiveFilter =
        searchController.text.isNotEmpty || selectedCategory != 'Semua';

    final List<Expense> filteredExpenses = (hasActiveFilter)
        ? expenses.where((expense) {
            bool matchesSearch = searchController.text.isEmpty ||
                expense.title.toLowerCase().contains(searchController.text.toLowerCase()) ||
                expense.description.toLowerCase().contains(searchController.text.toLowerCase());
            bool matchesCategory =
                selectedCategory == 'Semua' || expense.category == selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList()
        : expenses; // tampilkan semua jika tidak difilter

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          // Tidak perlu _loadInitialData() manual karena listener sudah handle
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kolom pencarian
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
              onChanged: (value) => _triggerFilter(),
            ),
            const SizedBox(height: 16),

            // Chip kategori
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [..._buildCategoryChips(categories)],
              ),
            ),
            const SizedBox(height: 25),

            // Kartu statistik
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    label: 'Total',
                    value: CurrencyUtils.formatCurrency(
                        _calculateFilteredTotal(filteredExpenses)),
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
                    value: CurrencyUtils.formatCurrency(
                        _calculateAverage(filteredExpenses)),
                    colors: [Colors.orange.shade400, Colors.orange.shade200],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Judul daftar
            const Text(
              "Daftar Pengeluaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),

            if (filteredExpenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('Belum ada pengeluaran.'),
                ),
              )
            else
              ...filteredExpenses
                  .map((expense) => _buildExpenseListItem(context, expense))
                  .toList(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- Komponen Pendukung ---
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
            _triggerFilter();
          },
        ),
      ),
      ...categories.map(
        (category) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(category.name),
            selected: selectedCategory == category.name,
            onSelected: (selected) {
              setState(() {
                selectedCategory = category.name;
              });
              _triggerFilter();
            },
          ),
        ),
      ),
    ];
  }

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
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }

  double _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return expenses.fold(0.0, (sum, e) => sum + e.amount) / expenses.length;
  }

  double _calculateFilteredTotal(List<Expense> expenses) {
    if (expenses.isEmpty) return 0.0;
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.green;
      case 'utilitas':
        return Colors.purple;
      case 'hiburan':
        return Colors.pink;
      case 'pendidikan':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'utilitas':
        return Icons.home;
      case 'hiburan':
        return Icons.movie;
      case 'pendidikan':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

  Widget _buildExpenseListItem(BuildContext context, Expense expense) {
    final isOwner = AuthService().currentUser?.uid == expense.ownerId;
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: _getCategoryColor(expense.category),
              child:
                  Icon(_getCategoryIcon(expense.category), color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(expense.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Text(
                        '${expense.category} • ${DateUtils.formatDate(expense.date)}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      if (!isOwner)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.share,
                              size: 16, color: Colors.blueAccent),
                        ),
                    ]),
                  ]),
            ),
            Text(
              CurrencyUtils.formatCurrency(expense.amount),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.red[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, Expense expense) {
    final isOwner = AuthService().currentUser?.uid == expense.ownerId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Jumlah',
                CurrencyUtils.formatCurrency(expense.amount), Colors.blue),
            _buildDetailRow('Kategori', expense.category, Colors.green),
            _buildDetailRow(
                'Tanggal', DateUtils.formatDate(expense.date), Colors.orange),
            _buildDetailRow('Deskripsi', expense.description, Colors.purple),
          ],
        ),
        actions: [
          if (isOwner)
            TextButton(
              onPressed: () async {
                await SharedService().loadExpenses();
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SharedProcessScreen(expense: expense),
                  ),
                );
                // Tidak perlu _loadInitialData(); listener handle otomatis
              },
              child: const Text('Share Data'),
            ),
          if (isOwner)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          EditExpenseScreen(expense: expense)),
                );
              },
              child: const Text('Edit'),
            ),
          if (isOwner)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Konfirmasi Hapus'),
                    content: const Text(
                        'Anda yakin ingin menghapus pengeluaran ini?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal')),
                      TextButton(
                        onPressed: () {
                          ExpenseService().deleteExpense(expense.id);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Hapus',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$label: ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ),
      ]),
    );
  }
}
