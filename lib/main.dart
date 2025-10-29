// main.dart

import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/mainscreen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home_screen.dart';
import 'service/expense_service.dart';
import 'route/AppRoutes.dart'; 
import 'service/auth_service.dart';
import 'screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Wajib: Memastikan SharedPreferences siap
  await SharedPreferences.getInstance();

  // Memuat data awal (Login dan Load data)
  await AuthService().login('Bulkigus', 'bull'); // Asumsi ini dimuat sebelum service lain
  await ExpenseService().loadInitialData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker Pro',
      routes: {
        // Tambahkan semua rute utama
        AppRoutes.onboarding: (context) => const OnboardingScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const MainScreen(),
        // Anda harus menambahkan rute lainnya di sini
      },
      // FIX KRUSIAL: Mulai dari Onboarding Screen
      initialRoute: AppRoutes.onboarding, 
    );
  }
}