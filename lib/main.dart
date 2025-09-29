// main.dart

import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'service/expense_service.dart';

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Memuat data awal dari penyimpanan in-memory
  // Ini harus dipanggil sebelum runApp()
  await ExpenseService().loadInitialData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}