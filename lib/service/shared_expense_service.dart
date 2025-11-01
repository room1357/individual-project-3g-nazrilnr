import '../models/expense.dart';
import 'auth_service.dart';
import 'persistent_storage_service.dart';
import '../models/user.dart';

class SharedService {
  static final SharedService _instance = SharedService._internal();
  factory SharedService() => _instance;
  SharedService._internal();

  final AuthService _authService = AuthService();
  final PersistentStorageService _storageService = PersistentStorageService();

  List<Expense> _expenses = [];

  Future<void> loadExpenses() async {
    _expenses = await _storageService.loadExpenses();
  }

  Future<void> shareExpense(Expense expense, List<String> participantNames) async {
    final updatedExpense = expense.copyWith(participantIds: participantNames);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
    } else {
      _expenses.add(updatedExpense);
    }
    await _storageService.saveExpenses(_expenses);
  }

  // Semua expense yang terkait dengan user (baik owner atau penerima)
  List<Expense> getExpensesForUser(String userName) {
    return _expenses.where((e) =>
        e.ownerId == _authService.getUserIdByName(userName) || e.participantIds.contains(userName)).toList();
  }

  // Riwayat dibagikan (owner)
  List<Expense> getSharedByUser(String userName) {
    return _expenses.where((e) => e.ownerId == _authService.getUserIdByName(userName) && e.participantIds.isNotEmpty).toList();
  }

  // Riwayat diterima (participant)
  List<Expense> getReceivedByUser(String userName) {
    return _expenses.where((e) => e.participantIds.contains(userName)).toList();
  }
}
