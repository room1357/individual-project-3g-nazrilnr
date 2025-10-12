import 'package:flutter/foundation.dart' hide Category;
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';
import 'auth_service.dart'; // Import service autentikasi

class ExpenseService extends ChangeNotifier {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final StorageService _storageService = InMemoryStorageService();
  // Dapatkan instance AuthService untuk mengecek user yang sedang login
  final AuthService _authService = AuthService(); 

  List<Expense> _expenses = [];
  List<Category> _categories = [];

  // INI ADALAH PERBAIKAN KRUSIAL UNTUK ISOLASI DATA
  List<Expense> get expenses {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return []; // Jika tidak ada user, kembalikan kosong

    // Filter: Tampilkan pengeluaran yang dimiliki user ATAU yang melibatkan user
    return List.unmodifiable(_expenses.where((e) {
        // Cek data yang baru diisi memiliki tag kepemilikan dan partisipan
        if (e.ownerId == null || e.participantIds == null) {
            // Abaikan data yang tidak memiliki tag (atau data lama yang tidak lengkap)
            return false; 
        }
        
        // Tampilkan hanya jika user adalah owner ATAU user ada di daftar partisipan
        return e.ownerId == currentUserId || e.participantIds.contains(currentUserId);
    }).toList());
  }

  List<Category> get categories => List.unmodifiable(_categories);

  // Metode untuk memuat data awal dari penyimpanan
  Future<void> loadInitialData() async {
    _expenses = await _storageService.loadExpenses();
    _categories = await _storageService.loadCategories();
    notifyListeners();
  }

  // --- Expense CRUD ---
  void addExpense(Expense e) {
    final nextId = (_expenses.length + 1).toString();
    
    // Buat objek final Expense dengan ID sequential dan tagging kepemilikan
    final finalExpense = Expense(
      id: nextId, 
      title: e.title,
      amount: e.amount,
      category: e.category,
      date: e.date,
      description: e.description,
      
      // PASTIKAN FIELD BARU DISIMPAN
      ownerId: e.ownerId, 
      participantIds: e.participantIds,
    );
    
    _expenses.add(finalExpense);
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

  // --- Category Management ---
  void addCategory(Category newCategory) {
    _categories.add(newCategory);
    _storageService.saveCategories(_categories);
    notifyListeners();
  }

  void deleteCategory(String id) {
    _categories.removeWhere((x) => x.id == id);
    _storageService.saveCategories(_categories);
    notifyListeners();
  }
}