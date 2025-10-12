import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // PANGGIL FUNGSI UNTUK MENGISI DATA DUMMY SAAT SERVICE DIBUAT
    _seedInitialUser();
  }

  // SIMULASI DATABASE PENGGUNA TERDAFTAR
  final Map<String, User> _registeredUsers = {};
  final Map<String, String> _userPasswords = {};


  User? _currentUser;
  User? get currentUser => _currentUser;

  // --- FUNGSI BARU: Mengisi Akun Dummy ---
  void _seedInitialUser() {
    const email = 'Bulkigus';
    const password = 'bull';
    
    final dummyUser = User(
      uid: 'admin_1', 
      email: email, 
      name: 'Testing User',
      origin: 'Jakarta',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(15, 09, 2005),
    );
    
    // Simpan akun dummy ke database
    _registeredUsers[email] = dummyUser;
    _userPasswords[email] = password;
    debugPrint('Akun Dummy Siap: $email / $password');
  }

  // Method untuk mendaftarkan user baru (Simulasi)
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_registeredUsers.containsKey(email)) {
      return 'Email sudah terdaftar.';
    }
    
    final newUser = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(), 
      email: email, 
      name: name
    );
    
    _registeredUsers[email] = newUser;
    _userPasswords[email] = password; 
    
    _currentUser = newUser;
    debugPrint('User baru terdaftar: ${newUser.email}');
    return null; 
  }

  // Method untuk login
  Future<String?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_registeredUsers.containsKey(email)) {
      return 'Akun belum terdaftar.';
    }
    
    if (_userPasswords[email] == password) {
      _currentUser = _registeredUsers[email];
      debugPrint('Login Sukses: ${_currentUser!.email}');
      return null;
    } else {
      return 'Email atau password salah.';
    }
  }

  // Method untuk logout
  Future<void> logout() async {
    _currentUser = null;
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  // Method untuk memperbarui detail user yang sedang login (Simulasi)
  Future<String?> updateProfile({
    required String name,
    required String origin,
    required String gender,
    required DateTime dateOfBirth,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return "User belum login.";
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Perbarui objek _currentUser di state
    final updatedUser = User(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      name: name,
      origin: origin,
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
    
    _currentUser = updatedUser;
    _registeredUsers[updatedUser.email] = updatedUser; // Update di "database"

    return null;
  }
}