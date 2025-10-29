import 'package:flutter/material.dart';
// NOTE: Ganti path sesuai struktur folder Anda jika ini tidak berfungsi
import 'home_screen.dart'; 
import 'statictic/statistic_screen.dart';
import 'advenced_expense/advenced_expense_list_screen.dart';
import 'profile/profile_screen.dart';
import 'category/category_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default ke Home

  // DAFTAR SEMUA LAYAR UTAMA
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const AdvancedExpenseListScreen(),
    const ProfileScreen(), // Shared (menggunakan Profile)
    const CategoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Judul AppBar agar sesuai dengan tab yang dipilih
  String get _currentTitle {
    switch (_selectedIndex) {
      case 0: return 'Home';
      case 1: return 'Statistik Pengeluaran';
      case 2: return 'Pengeluaran Advanced';
      case 3: return 'Shared';
      case 4: return 'Kategori';
      default: return 'Aplikasi Keuangan';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hanya ada SATU Scaffold di sini
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: IndexedStack(
        // IndexedStack mempertahankan keadaan (state) dari setiap layar
        index: _selectedIndex,
        children: _screens,
      ),
      
      // BOTTOM NAVIGATION BAR PERMANEN
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Statistik'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Pengeluaran'),
          BottomNavigationBarItem(icon: Icon(Icons.share), label: 'Shared'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Kategori'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}