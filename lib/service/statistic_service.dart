import 'package:flutter/foundation.dart';
import 'expense_service.dart';

class StatisticsService extends ChangeNotifier {
  final ExpenseService _expenseService;

  StatisticsService(this._expenseService) {
    // Dengarkan perubahan dari ExpenseService
    _expenseService.addListener(_onExpenseUpdated);
  }

  void _onExpenseUpdated() {
    notifyListeners(); // Kasih tahu UI kalau ada data baru
  }

  // Total semua pengeluaran
  double get totalAll =>
      _expenseService.expenses.fold(0.0, (s, e) => s + e.amount);

  // Total per kategori
  Map<String, double> get totalPerCategory {
    final map = <String, double>{};
    for (final e in _expenseService.expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  // Total per bulan (bisa tambahkan tahun jika dibutuhkan)
  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final e in _expenseService.expenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.amount;
    }
    return map;
  }

  // Total per kategori untuk bulan tertentu
  Map<String, double> getTotalPerCategoryForMonth(int month) {
    final totalPerCategory = <String, double>{};
    final expensesInMonth = _expenseService.expenses
        .where((e) => e.date.month == month)
        .toList();

    for (var expense in expensesInMonth) {
      totalPerCategory.update(
        expense.category,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return totalPerCategory;
  }

  @override
  void dispose() {
    _expenseService.removeListener(_onExpenseUpdated);
    super.dispose();
  }
}
