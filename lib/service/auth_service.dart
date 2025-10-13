import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Memanggil fungsi untuk mengisi data dummy saat service dibuat
    _seedInitialUser();
  }

  // SIMULASI DATABASE PENGGUNA TERDAFTAR
  final Map<String, User> _registeredUsers = {};
  final Map<String, String> _userPasswords = {};

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Mengisi Akun Dummy (Admin untuk tujuan pengujian)
  void _seedInitialUser() {
    const email = 'Bulkigus';
    const password = 'bull';
    
    final dummyAdmin = User(
      uid: 'admin_1', 
      email: email, 
      name: 'Admin Finance',
      role: 'admin', // ROLE DITETAPKAN
      origin: 'Jakarta',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(1990, 1, 1),
      profileImageUrl: "assets/images/profil.jpg", // Admin memiliki foto default
    );
    
    _registeredUsers[email] = dummyAdmin;
    _userPasswords[email] = password;
    debugPrint('Akun Admin Siap: $email / $password');
  }

  // Method untuk mendaftarkan user baru
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_registeredUsers.containsKey(email)) {
      return 'Email sudah terdaftar.';
    }
    
    final newUser = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(), 
      email: email, 
      name: name,
      role: 'user', // ROLE Default sebagai 'user' biasa
      profileImageUrl: null, // User baru dimulai dengan foto kosong
    );
    
    _registeredUsers[email] = newUser;
    _userPasswords[email] = password; 
    
    _currentUser = newUser;
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
  
  // Method untuk memperbarui detail user
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
      profileImageUrl: profileImageUrl,
      role: _currentUser!.role, // Pertahankan role lama
    );
    
    _currentUser = updatedUser;
    _registeredUsers[updatedUser.email] = updatedUser; // Update di "database"

    return null;
  }
}