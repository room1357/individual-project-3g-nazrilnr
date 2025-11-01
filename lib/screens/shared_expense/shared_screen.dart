import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../service/shared_expense_service.dart';
import '../../service/auth_service.dart';

class SharedExpenseScreen extends StatefulWidget {
  const SharedExpenseScreen({super.key});

  @override
  State<SharedExpenseScreen> createState() => _SharedExpenseScreenState();
}

class _SharedExpenseScreenState extends State<SharedExpenseScreen> {
  final SharedService _sharedService = SharedService();
  final AuthService _authService = AuthService();

  List<Expense> sentExpenses = [];
  List<Expense> receivedExpenses = [];

  @override
  void initState() {
    super.initState();
    _sharedService.expensesNotifier.addListener(_updateExpenses);
    _loadExpenses();
  }

  void _loadExpenses() async {
    await _sharedService.loadExpenses();
    _updateExpenses();
  }

  void _updateExpenses() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      sentExpenses = _sharedService.getSharedByUser(currentUser.name);
      receivedExpenses = _sharedService.getReceivedByUser(currentUser.name);
    });
  }

  void _openDetail(Expense expense) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(expense.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah: ${expense.amount}'),
              Text('Kategori: ${expense.category}'),
              Text('Tanggal: ${expense.date}'),
              Text('Deskripsi: ${expense.description}'),
              Text('Owner: ${expense.ownerName}'),
              Text('Dibagikan ke: ${expense.participantIds.join(', ')}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sharedService.expensesNotifier.removeListener(_updateExpenses);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shared Expense'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Dibagikan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(sentExpenses),
            _buildList(receivedExpenses),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Expense> list) {
    if (list.isEmpty) {
      return const Center(child: Text('Belum ada expense.'));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final e = list[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              e.title,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Jumlah: ${e.amount}\nDeskripsi: ${e.description}',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openDetail(e),
          ),
        );
      },
    );
  }
}
