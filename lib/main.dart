// main.dart

import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart'; // Pastikan Anda mengimpor RegisterScreen
import 'screens/home_screen.dart';        // Pastikan Anda mengimpor HomeScreen
import 'service/expense_service.dart';
import 'route/AppRoutes.dart'; 
import 'service/auth_service.dart';


void main() async {
  // Pastikan binding Flutter sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();
  
  // Memuat data awal dari penyimpanan in-memory
  await AuthService().login('Bulkigus', 'bull');
  await ExpenseService().loadInitialData();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      debugShowCheckedModeBanner: false,
      routes: {
        // Namun, pastikan instance widget di dalamnya adalah 'const'
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        // ... rute lainnya
      },
      initialRoute: AppRoutes.login,
    );
  }
}