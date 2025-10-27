import 'package:flutter/material.dart';
import 'package:pemrograman_mobile/route/AppRoutes.dart';
import 'package:pemrograman_mobile/service/auth_service.dart';
import '../../service/expense_service.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Controller untuk verifikasi
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Periksa kecocokan password sebelum memanggil service
    if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi Gagal: Password dan Konfirmasi tidak cocok.')),
        );
        return;
    }

    setState(() { _isLoading = true; });

    // Panggil AuthService untuk mendaftarkan user baru
    final errorMessage = await AuthService().register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );
    
    setState(() { _isLoading = false; });

    if (errorMessage == null) {
      // Muat data expense dan kategori user baru setelah register sukses
      await ExpenseService().loadInitialData(); 

      // Navigasi ke Home dan hapus semua rute sebelumnya
      Navigator.pushNamedAndRemoveUntil(
        context, 
        AppRoutes.home, 
        (route) => false
      );
    } else {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi Gagal: $errorMessage')),
      );
    }
  }
  
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text("Buat Akun Baru", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 24),

                // 1. Field Nama LENGKAP
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration('Nama Lengkap'),
                  validator: (value) => value!.isEmpty ? 'Nama harus diisi' : null, 
                ),
                const SizedBox(height: 16),

                // 2. Field Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration('Email'),
                  validator: (value) => value!.isEmpty || !value.contains('@') ? 'Masukkan email yang valid' : null,
                ),
                const SizedBox(height: 16),

                // 3. Field Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Password'),
                  validator: (value) => value!.length < 6 ? 'Password minimal 6 karakter' : null,
                ),
                const SizedBox(height: 16), 

                // 4. Field Konfirmasi Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: _inputDecoration('Konfirmasi Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Konfirmasi password harus diisi';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Register
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('DAFTAR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),

                // Link ke Login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sudah punya akun? Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}