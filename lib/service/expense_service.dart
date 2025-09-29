import 'package:flutter/foundation.dart' hide Category;
import '../models/expense.dart';
import '../models/category.dart'; // Pastikan ini mengimpor kelas Category
import 'storage_service.dart';

// Implementasi singleton untuk ExpenseService
class ExpenseService extends ChangeNotifier {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final StorageService _storageService = InMemoryStorageService();

  List<Expense> _expenses = [];
  List<Category> _categories = []; // Diperbaiki: CategoryModel -> Category

  List<Expense> get expenses => List.unmodifiable(_expenses);
  List<Category> get categories => List.unmodifiable(_categories); // Diperbaiki: CategoryModel -> Category

  // Metode untuk memuat data awal dari penyimpanan
  Future<void> loadInitialData() async {
    _expenses = await _storageService.loadExpenses();
    _categories = await _storageService.loadCategories(); // Diperbaiki: CategoryModel -> Category
    notifyListeners();
  }

  // Metode-metode CRUD yang memanggil storage service
  void addExpense(Expense e) {
    _expenses.add(e);
    _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((x) => x.id == id);
    _storageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void updateExpense(Expense updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      _storageService.saveExpenses(_expenses);
      notifyListeners();
    }
  }

  void addCategory(Category newCategory) {
    // Tambah kategori baru
    _categories.add(newCategory);
    _storageService.saveCategories(_categories);
    notifyListeners();
  }

  void deleteCategory(String id) {
    // Hapus kategori berdasarkan ID
    _categories.removeWhere((x) => x.id == id);
    _storageService.saveCategories(_categories);
    notifyListeners();
  }
}