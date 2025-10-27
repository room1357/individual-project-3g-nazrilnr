import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../route/AppRoutes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi tampilan PageView
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.blue),
      bodyTextStyle: TextStyle(fontSize: 16.0),
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    // Daftar semua halaman onboarding
    final pages = [
      PageViewModel(
        title: "Selamat Datang di ExpensePro",
        body: "Aplikasi ini membantu Anda melacak, mengatur, dan menganalisis setiap rupiah pengeluaran Anda dengan mudah.",
        image: const Icon(Icons.account_balance_wallet, size: 150, color: Colors.blue),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Kategori dan Filter Cepat",
        body: "Atur pengeluaran ke dalam kategori khusus (Makanan, Transportasi, dll.) dan gunakan filter advanced untuk wawasan instan.",
        image: const Icon(Icons.category, size: 150, color: Colors.teal),
        decoration: pageDecoration,
      ),
      PageViewModel(
        title: "Statistik dan Laporan",
        body: "Lihat diagram Pie Chart dan Bar Chart bulanan. Anda juga dapat mengekspor data ke format CSV dan PDF.",
        image: const Icon(Icons.analytics, size: 150, color: Colors.purple),
        decoration: pageDecoration,
      ),
    ];

    return IntroductionScreen(
      pages: pages,
      onDone: () {
        // Navigasi ke Login Screen setelah selesai
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
      onSkip: () {
        // Navigasi ke Login Screen jika user memilih Skip
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      },
      showSkipButton: true,
      skip: const Text('Lewati', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Selesai', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }
}