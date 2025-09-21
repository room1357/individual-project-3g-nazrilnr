import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../managers/expense_manager.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> allExpenses = ExpenseManager.expenses; // data asli
  List<Expense> filteredExpenses = ExpenseManager.expenses; // hasil filter
  String keyword = "";

  @override
  Widget build(BuildContext context) {
    final highestExpense = ExpenseManager.getHighestExpense(filteredExpenses);
    final averageDaily = ExpenseManager.getAverageDaily(filteredExpenses);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengeluaran'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Cari pengeluaran...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  keyword = value;
                  filteredExpenses = ExpenseManager.searchExpenses(allExpenses, keyword);
                });
              },
            ),
          ),

          // Header ringkasan
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade200),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Total Pengeluaran", _calculateTotal(filteredExpenses)),
                SizedBox(height: 8),
                _buildSummaryRow(
                  "Pengeluaran Tertinggi",
                  highestExpense != null
                      ? "${highestExpense.title} - ${highestExpense.formattedAmount}"
                      : "-",
                ),
                SizedBox(height: 8),
                _buildSummaryRow(
                  "Rata-rata Harian",
                  "Rp ${averageDaily.toStringAsFixed(0)}",
                ),
              ],
            ),
          ),

          // ListView pengeluaran
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(child: Text("Tidak ada pengeluaran ditemukan"))
                : ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(expense.category),
                            child: Icon(
                              _getCategoryIcon(expense.category),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(expense.title,
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense.category,
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12)),
                              Text(expense.formattedDate,
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 11)),
                            ],
                          ),
                          trailing: Text(
                            expense.formattedAmount,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red[600]),
                          ),
                          onTap: () {
                            _showExpenseDetails(context, expense);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Ringkasan data
  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800])),
      ],
    );
  }

  String _calculateTotal(List<Expense> expenses) {
    double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
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

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(expense.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jumlah: ${expense.formattedAmount}'),
            SizedBox(height: 8),
            Text('Kategori: ${expense.category}'),
            SizedBox(height: 8),
            Text('Tanggal: ${expense.formattedDate}'),
            SizedBox(height: 8),
            Text('Deskripsi: ${expense.description}'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Tutup')),
        ],
      ),
    );
  }
}
