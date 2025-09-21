import '../models/expense.dart';
import '../managers/expense_manager.dart';

class LoopingExamples {
  // Ambil langsung dari ExpenseManager
  static List<Expense> get expenses => ExpenseManager.expenses;

  // 1. Menghitung total dengan berbagai cara

  // Cara 1: For loop tradisional
  static double calculateTotalTraditional() {
    double total = 0;
    for (int i = 0; i < expenses.length; i++) {
      total += expenses[i].amount;
    }
    return total;
  }

  // Cara 2: For-in loop
  static double calculateTotalForIn() {
    double total = 0;
    for (Expense expense in expenses) {
      total += expense.amount;
    }
    return total;
  }

  // Cara 3: forEach method
  static double calculateTotalForEach() {
    double total = 0;
    expenses.forEach((expense) {
      total += expense.amount;
    });
    return total;
  }

  // Cara 4: fold method
  static double calculateTotalFold() {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  // Cara 5: reduce method
  static double calculateTotalReduce() {
    if (expenses.isEmpty) return 0;
    return expenses.map((e) => e.amount).reduce((a, b) => a + b);
  }

  // 2. Mencari item dengan berbagai cara

  // Cara 1: For loop dengan break
  static Expense? findExpenseTraditional(String id) {
    for (int i = 0; i < expenses.length; i++) {
      if (expenses[i].id == id) {
        return expenses[i];
      }
    }
    return null;
  }

  // Cara 2: firstWhere method
  static Expense? findExpenseWhere(String id) {
    try {
      return expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  // 3. Filtering dengan berbagai cara

  // Cara 1: Loop manual dengan List.add()
  static List<Expense> filterByCategoryManual(String category) {
    List<Expense> result = [];
    for (Expense expense in expenses) {
      if (expense.category.toLowerCase() == category.toLowerCase()) {
        result.add(expense);
      }
    }
    return result;
  }

  // Cara 2: where method
  static List<Expense> filterByCategoryWhere(String category) {
    return expenses
        .where((expense) => expense.category.toLowerCase() == category.toLowerCase())
        .toList();
  }
}
