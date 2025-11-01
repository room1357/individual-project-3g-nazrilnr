import '../models/user.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _seedInitialUser(); // Seed admin default (bisa dihapus kalau mau kosong)
  }

  // Simulasi database pengguna terdaftar
  final Map<String, User> _registeredUsers = {};
  final Map<String, String> _userPasswords = {};

  User? _currentUser;
  User? get currentUser => _currentUser;

  // Buat satu admin default agar sistem bisa diuji
  void _seedInitialUser() {
    const email = 'Bulkigus';
    const password = 'bull';
    
    final dummyAdmin = User(
      uid: 'admin_1', 
      email: email, 
      name: 'Muhammad Nazril Nur Rahman',
      role: 'admin',
      origin: 'Malang',
      gender: 'Laki-laki',
      dateOfBirth: DateTime(2005, 9, 15),
      profileImageUrl: "assets/images/profil.jpg",
    );
    
    _registeredUsers[email] = dummyAdmin;
    _userPasswords[email] = password;
    debugPrint('Akun Admin Siap: $email / $password');
  }

  // Mendaftarkan user baru
  Future<String?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_registeredUsers.containsKey(email)) {
      return 'Email sudah terdaftar.';
    }
    
    final newUser = User(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: 'user',
      profileImageUrl: null,
    );
    
    _registeredUsers[email] = newUser;
    _userPasswords[email] = password;
    
    _currentUser = newUser;
    return null;
  }

  // Login user
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

  // Logout user
  Future<void> logout() async {
    _currentUser = null;
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Update profil user
  Future<String?> updateProfile({
    required String name,
    required String origin,
    required String gender,
    required DateTime dateOfBirth,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return "User belum login.";
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final updatedUser = User(
      uid: _currentUser!.uid,
      email: _currentUser!.email,
      name: name,
      origin: origin,
      gender: gender,
      dateOfBirth: dateOfBirth,
      profileImageUrl: profileImageUrl,
      role: _currentUser!.role,
    );
    
    _currentUser = updatedUser;
    _registeredUsers[updatedUser.email] = updatedUser;

    return null;
  }

  // 🔹 Ambil UID berdasarkan nama
  String? getUserIdByName(String name) {
    try {
      final user = _registeredUsers.values.firstWhere((u) => u.name == name);
      return user.uid;
    } catch (_) {
      return null;
    }
  }

  // 🔹 Ambil nama berdasarkan UID
  String getUserNameById(String id) {
    try {
      final user = _registeredUsers.values.firstWhere((u) => u.uid == id);
      return user.name;
    } catch (_) {
      return 'Unknown';
    }
  }

  // 🔹 Ambil semua user
  List<User> getAllUsers() {
    return _registeredUsers.values.toList();
  }

  // 🔹 Cek apakah ada user login
  bool get isLoggedIn => _currentUser != null;
}
