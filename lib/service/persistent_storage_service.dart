import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../models/category.dart';

// --- Antarmuka Abstraksi StorageService (Wajib Ada) ---
abstract class StorageService {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> items);

  Future<List<Category>> loadCategories();
  Future<void> saveCategories(List<Category> items);
}

/// Implementasi penyimpanan persisten menggunakan SharedPreferences (Simulasi Sinkronisasi Data).
/// Kelas ini menggunakan toJson() dan fromJson() dari model Expense dan Category.
class PersistentStorageService implements StorageService {
  
  static const String _expenseKey = 'user_expenses_data';
  static const String _categoryKey = 'user_categories_data';

  // --- Load Expenses ---
  @override
  Future<List<Expense>> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_expenseKey);

    if (jsonString == null) return [];

    try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        // Deserialisasi: Mengonversi Map JSON kembali menjadi objek Expense
        return jsonList.map((json) => Expense.fromJson(json)).toList();
    } catch (e) {
        // Jika ada error dalam decoding (data rusak), kembalikan list kosong
        return []; 
    }
  }

  // --- Save Expenses ---
  @override
  Future<void> saveExpenses(List<Expense> items) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Serialisasi: Mengonversi List<Expense> menjadi String JSON
    final jsonList = items.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(_expenseKey, jsonString);
  }

  // --- Load Categories ---
  @override
  Future<List<Category>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoryKey);

    if (jsonString == null) return []; 
    
    try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        // Deserialisasi: Mengonversi Map JSON kembali menjadi objek Category
        return jsonList.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
        return [];
    }
  }

  // --- Save Categories ---
  @override
  Future<void> saveCategories(List<Category> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((e) => e.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    
    await prefs.setString(_categoryKey, jsonString);
  }
}