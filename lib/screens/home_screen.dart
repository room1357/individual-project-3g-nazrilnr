import 'package:flutter/material.dart' hide DateUtils;
import 'dart:io'; 
import 'package:pemrograman_mobile/route/AppRoutes.dart';
import 'profile/profile_screen.dart';
import 'setting/pengaturan_screen.dart';
import '../../service/auth_service.dart';
import '../../service/expense_service.dart';
import '../../models/expense.dart';
import '../../utils/currency_utils.dart';
import '../../utils/date_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final ExpenseService _expenseService = ExpenseService();
  Future<void>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadInitialData();
    _expenseService.addListener(_refreshData);
  }

  @override
  void dispose() {
    _expenseService.removeListener(_refreshData);
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await _expenseService.loadInitialData();
    setState(() {});
  }

  void _refreshData() {
    if (mounted) setState(() {});
  }

  // Fungsi untuk menentukan gambar profil
  ImageProvider<Object>? _getProfileImageProvider(String? path) {
    if (path == null) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    try {
      if (File(path).existsSync()) {
        return FileImage(File(path));
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  // Ikon kategori
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return Icons.restaurant;
      case 'transportasi':
        return Icons.directions_car;
      case 'utilitas':
        return Icons.home;
      case 'hiburan':
        return Icons.movie;
      case 'pendidikan':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }

  // Item daftar transaksi (tanpa navigasi edit)
  Widget _buildTransactionListItem(BuildContext context, Expense expense) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(
          _getCategoryIcon(expense.category),
          color: Colors.blue.shade700,
          size: 20,
        ),
      ),
      title: Text(
        expense.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle:
          Text('${expense.category} - ${DateUtils.formatDate(expense.date)}'),
      trailing: Text(
        CurrencyUtils.formatCurrency(expense.amount),
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.red.shade600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final expenses = _expenseService.expenses;

    // Data bulan ini
    final currentMonth = DateTime.now().month;
    final monthlyExpenses =
        expenses.where((e) => e.date.month == currentMonth).toList();
    final totalMonthlyExpense =
        monthlyExpenses.fold(0.0, (sum, item) => sum + item.amount);

    // Urutkan transaksi terbaru
    final sortedExpenses = List.of(expenses);
    sortedExpenses.sort((a, b) => b.date.compareTo(a.date));
    final recentTransactions = sortedExpenses.take(5).toList();

    final ImageProvider<Object>? profileImageProvider =
        _getProfileImageProvider(user?.profileImageUrl);
    final bool hasProfileImage = profileImageProvider != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen())),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: profileImageProvider,
                child: hasProfileImage
                    ? null
                    : Icon(Icons.person,
                        size: 20, color: Colors.blue.shade800),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Halo, ${user?.name.split(' ').first ?? 'User'}!",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const Text(
                  "Selamat datang kembali",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.settings, color: Colors.black54),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PengaturanScreen()))),
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.red),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (route) => false)),
        ],
      ),
      body: FutureBuilder<void>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu total bulanan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.green.shade400,
                        Colors.teal.shade500
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Pengeluaran Bulan Ini",
                          style: TextStyle(
                              color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(CurrencyUtils.formatCurrency(totalMonthlyExpense),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${monthlyExpenses.length} transaksi',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Riwayat transaksi
                const Text("Riwayat Transaksi Terakhir",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87)),
                const SizedBox(height: 10),

                recentTransactions.isEmpty
                    ? const Center(
                        child: Text("Belum ada transaksi yang dicatat."),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentTransactions.length,
                        itemBuilder: (context, index) {
                          final expense = recentTransactions[index];
                          return _buildTransactionListItem(context, expense);
                        },
                      ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
