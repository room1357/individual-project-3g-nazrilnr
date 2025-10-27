import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/screens/statictic/statistic_screen.dart';
import 'auth/login_screen.dart';
import 'profile/profile_screen.dart';
import 'message/pesan_screen.dart';
import 'setting/pengaturan_screen.dart';
import 'advenced_expense/advenced_expense_list_screen.dart';
import 'category/category_screen.dart';
import 'expense_list_screen.dart';
import 'export/export_screen.dart';
import 'apitest/api_post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selamat Datang 👋",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Pantau dan atur pengeluaranmu",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
                // Avatar bisa ditekan menuju profil
                InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: AssetImage(""),
                  ),
                )
              ],
            ),

            const SizedBox(height: 25),

            // Dashboard Menu (tanpa Profil lagi)
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // _buildMenuCard(
                //   context,
                //   title: "Pengeluaran",
                //   icon: Icons.attach_money,
                //   colors: [Colors.green.shade400, Colors.green.shade200],
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => const ExpenseListScreen()),
                //     );
                //   },
                // ),
                _buildMenuCard(
                  context,
                  title: "Pengeluaran Advanced",
                  icon: Icons.payment,
                  colors: [Colors.blue.shade400, Colors.blue.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdvancedExpenseListScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "Statistik",
                  icon: Icons.analytics,
                  colors: [Colors.teal.shade400, Colors.teal.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "Kategori",
                  icon: Icons.category,
                  colors: [Colors.teal.shade400, Colors.teal.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoryScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "Ekspor Data",
                  icon: Icons.upload_file,
                  colors: [Colors.indigo.shade400, Colors.indigo.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExportScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "Pesan",
                  icon: Icons.message,
                  colors: [Colors.orange.shade400, Colors.orange.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PesanScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "Pengaturan",
                  icon: Icons.settings,
                  colors: [Colors.purple.shade400, Colors.purple.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PengaturanScreen()),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  title: "PostAPI",
                  icon: Icons.settings,
                  colors: [Colors.purple.shade400, Colors.purple.shade200],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ApiPostsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 30, // biar 2 kolom
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(2, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
