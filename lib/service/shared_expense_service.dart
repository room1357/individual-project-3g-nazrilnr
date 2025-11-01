import '../models/expense.dart';
import 'auth_service.dart';
import 'persistent_storage_service.dart';
import 'package:flutter/foundation.dart';

class SharedService {
  static final SharedService _instance = SharedService._internal();
  factory SharedService() => _instance;
  SharedService._internal();

  final AuthService _authService = AuthService();
  final PersistentStorageService _storageService = PersistentStorageService();

  // ValueNotifier agar bisa auto update screen
  final ValueNotifier<List<Expense>> expensesNotifier = ValueNotifier([]);

  List<Expense> get _expenses => expensesNotifier.value;

  Future<void> loadExpenses() async {
    final loaded = await _storageService.loadExpenses();
    expensesNotifier.value = loaded;
  }

  Future<void> shareExpense(Expense expense, List<String> participantNames) async {
    final updatedExpense = expense.copyWith(participantIds: participantNames);
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    List<Expense> newList = List.from(_expenses);

    if (index != -1) {
      newList[index] = updatedExpense;
    } else {
      newList.add(updatedExpense);
    }

    expensesNotifier.value = newList;
    await _storageService.saveExpenses(newList);
  }

  List<Expense> getSharedByUser(String userName) {
    return _expenses.where((e) =>
        e.ownerId == _authService.getUserIdByName(userName) &&
        e.participantIds.isNotEmpty).toList();
  }

  List<Expense> getReceivedByUser(String userName) {
    return _expenses.where((e) => e.participantIds.contains(userName)).toList();
  }
}
