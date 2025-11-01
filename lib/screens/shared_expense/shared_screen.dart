import 'package:flutter/material.dart';
import '../../service/auth_service.dart';
import '../../service/shared_expense_service.dart';
import '../../models/expense.dart';

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
    _loadExpenses();
  }

  void _loadExpenses() async {
    await _sharedService.loadExpenses();
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      sentExpenses = _sharedService.getSharedByUser(currentUser.name);
      receivedExpenses = _sharedService.getReceivedByUser(currentUser.name);
    });
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
            _buildList(sentExpenses, true),
            _buildList(receivedExpenses, false),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Expense> list, bool isOwner) {
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
            title: Text(e.title),
            subtitle: Text(
              'Jumlah: ${e.amount}\nDeskripsi: ${e.description}\n'
              '${isOwner ? 'Dibagikan ke: ' : 'Dari: '}${isOwner ? e.participantIds.join(', ') : e.ownerId}',
            ),
          ),
        );
      },
    );
  }
}
