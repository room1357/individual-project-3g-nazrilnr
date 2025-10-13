import 'package:flutter/foundation.dart' hide Category;
import '../models/expense.dart';
import '../models/category.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ExpenseService extends ChangeNotifier {
  static final ExpenseService _instance = ExpenseService._internal();
  factory ExpenseService() => _instance;
  ExpenseService._internal();

  final StorageService _storageService = InMemoryStorageService();
  final AuthService _authService = AuthService(); 
  
  // ID Admin yang Anda definisikan di AuthService
  static const String _ADMIN_ID = 'admin_1'; 

  // Master list untuk menyimpan SEMUA kategori (dari semua pengguna)
  List<Expense> _expenses = [];
  List<Category> _allCategories = []; // FIX: Ganti _categories menjadi _allCategories

  // Getter expenses tetap benar (sudah memfilter berdasarkan ownerId/participantIds)
  List<Expense> get expenses {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return [];

    return List.unmodifiable(_expenses.where((e) {
        if (e.ownerId == null || e.participantIds == null) {
            return false; 
        }
        return e.ownerId == currentUserId || e.participantIds.contains(currentUserId);
    }).toList());
  }

  // FIX KRUSIAL: Getter categories memfilter master list berdasarkan user ID
  List<Category> get categories {
    final currentUserId = _authService.currentUser?.uid;
    if (currentUserId == null) return [];

    // Filter master list categories
    return List.unmodifiable(_allCategories.where((c) => c.userId == currentUserId).toList());
  }

  // Helper: Kategori Default (untuk di-seed ke Admin)
  List<Category> _createDefaultCategoriesForAdmin(String userId) {
      return [
        Category(id: 'c1', name: 'Makanan', userId: userId),
        Category(id: 'c2', name: 'Transportasi', userId: userId),
        Category(id: 'c3', name: 'Utilitas', userId: userId),
        Category(id: 'c4', name: 'Hiburan', userId: userId),
        Category(id: 'c5', name: 'Pendidikan', userId: userId),
      ];
  }

  // --- PERBAIKAN DI loadInitialData ---
  Future<void> loadInitialData() async {
    final currentUserId = _authService.currentUser?.uid;

    _expenses = await _storageService.loadExpenses();
    // Memuat SEMUA kategori yang tersimpan
    _allCategories = await _storageService.loadCategories(); 
    
    // Logika Kategori Default: Hanya buat jika list kosong DAN yang login adalah admin
    if (_allCategories.isEmpty) {
      if (currentUserId == _ADMIN_ID) {
         _allCategories = _createDefaultCategoriesForAdmin(_ADMIN_ID);
         _storageService.saveCategories(_allCategories);
      }
    }
    
    notifyListeners();
  }

  // --- Expense CRUD ---
  void addExpense(Expense e) {
    final nextId = (_expenses.length + 1).toString();
    
    final finalExpense = Expense(
      id: nextId, 
      title: e.title,
      amount: e.amount,
      category: e.category,
      date: e.date,
      description: e.description,
      
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
    // FIX: Tambahkan ke master list
    _allCategories.add(newCategory);
    _storageService.saveCategories(_allCategories);
    notifyListeners();
  }

  void deleteCategory(String id) {
    // FIX: Hapus dari master list
    _allCategories.removeWhere((x) => x.id == id);
    _storageService.saveCategories(_allCategories);
    notifyListeners();
  }
}