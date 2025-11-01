import 'package:flutter/material.dart';
import '../../models/expense.dart';
import '../../service/shared_expense_service.dart';
import '../../service/auth_service.dart';

class SharedProcessScreen extends StatefulWidget {
  final Expense expense;
  const SharedProcessScreen({super.key, required this.expense});

  @override
  State<SharedProcessScreen> createState() => _SharedProcessScreenState();
}

class _SharedProcessScreenState extends State<SharedProcessScreen> {
  final SharedService _sharedService = SharedService();
  final AuthService _authService = AuthService();

  List<String> selectedNames = [];

  @override
  void initState() {
    super.initState();
    selectedNames = List.from(widget.expense.participantIds);
  }

  void _shareExpense() async {
    await _sharedService.shareExpense(widget.expense, selectedNames);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense berhasil dibagikan!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allUsers = _authService.getAllUsers().where((u) => u.uid != widget.expense.ownerId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bagikan Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Expense: ${widget.expense.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: allUsers.map((user) {
                  final isSelected = selectedNames.contains(user.name);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(user.name),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selectedNames.add(user.name);
                        } else {
                          selectedNames.remove(user.name);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: _shareExpense,
              child: const Text('Bagikan'),
            ),
          ],
        ),
      ),
    );
  }
}
