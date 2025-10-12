import 'dart:async';
import '../models/expense.dart';
import '../models/category.dart';

abstract class StorageService {
  Future<List<Expense>> loadExpenses();
  Future<void> saveExpenses(List<Expense> items);

  Future<List<Category>> loadCategories();
  Future<void> saveCategories(List<Category> items);
}

/// Implementasi penyimpanan sementara (in-memory).
class InMemoryStorageService implements StorageService {
  List<Expense> _expenses = [];
  List<Category> _categories = [];

  // Definisikan ID Admin/Dummy untuk penanda kepemilikan (sesuai AuthService)
  static const String _dummyAdminId = 'admin_1';

  @override
  Future<List<Expense>> loadExpenses() async {
    // Memuat data dummy jika daftar kosong
    if (_expenses.isEmpty) {
      _expenses = [
        Expense(
          id: '1',
          title: 'Belanja Bulanan',
          amount: 150000,
          category: 'Makanan',
          date: DateTime(2024, 9, 15),
          description: 'Supermarket',
          ownerId: _dummyAdminId,             // FIX: Tambahkan ownerId
          participantIds: [_dummyAdminId],    // FIX: Tambahkan participantIds
        ),
        Expense(
          id: '2',
          title: 'Bensin Motor',
          amount: 50000,
          category: 'Transportasi',
          date: DateTime(2024, 9, 14),
          description: 'Pertalite',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '3',
          title: 'Kopi di Cafe',
          amount: 25000,
          category: 'Makanan',
          date: DateTime(2024, 9, 14),
          description: 'Ngopi',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '4',
          title: 'Tagihan Internet',
          amount: 300000,
          category: 'Utilitas',
          date: DateTime(2024, 9, 13),
          description: 'Bulanan',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '5',
          title: 'Tiket Bioskop',
          amount: 100000,
          category: 'Hiburan',
          date: DateTime(2024, 9, 12),
          description: 'Nonton film weekend bersama keluarga',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '6',
          title: 'Beli Buku',
          amount: 75000,
          category: 'Pendidikan',
          date: DateTime(2024, 9, 11),
          description: 'Buku pemrograman untuk belajar',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '7',
          title: 'Makan Siang',
          amount: 35000,
          category: 'Makanan',
          date: DateTime(2024, 9, 11),
          description: 'Makan siang di restoran',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
        Expense(
          id: '8',
          title: 'Ongkos Bus',
          amount: 10000,
          category: 'Transportasi',
          date: DateTime(2024, 9, 10),
          description: 'Ongkos perjalanan harian ke kampus',
          ownerId: _dummyAdminId,
          participantIds: [_dummyAdminId],
        ),
      ];
    }
    return Future.value(List.of(_expenses));
  }

  @override
  Future<void> saveExpenses(List<Expense> items) async {
    _expenses = List.of(items);
  }

  @override
  Future<List<Category>> loadCategories() async {
    // Memuat data dummy jika daftar kosong
    if (_categories.isEmpty) {
      _categories = [
        Category(id: 'c1', name: 'Makanan'),
        Category(id: 'c2', name: 'Transportasi'),
        Category(id: 'c3', name: 'Utilitas'),
        Category(id: 'c4', name: 'Hiburan'),
        Category(id: 'c5', name: 'Pendidikan'),
      ];
    }
    return Future.value(List.of(_categories));
  }

  @override
  Future<void> saveCategories(List<Category> items) async {
    _categories = List.of(items);
  }
}