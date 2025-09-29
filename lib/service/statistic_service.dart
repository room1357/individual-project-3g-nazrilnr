import '../models/expense.dart';
import 'expense_service.dart';

class StatisticsService {
  final ExpenseService _expenseService;

  StatisticsService(this._expenseService);

  // Getter untuk menghitung total semua pengeluaran
  double get totalAll {
    return _expenseService.expenses.fold(0.0, (s, e) => s + e.amount);
  }

  // Getter untuk menghitung total pengeluaran per kategori
  Map<String, double> get totalPerCategory {
    final map = <String, double>{};
    for (final e in _expenseService.expenses) {
      map[e.category] = (map[e.category] ?? 0.0) + e.amount;
    }
    return map;
  }

  // Getter untuk menghitung total pengeluaran per bulan
  Map<int, double> get totalPerMonth {
    final map = <int, double>{};
    for (final e in _expenseService.expenses) {
      map[e.date.month] = (map[e.date.month] ?? 0.0) + e.amount;
    }
    return map;
  }
}