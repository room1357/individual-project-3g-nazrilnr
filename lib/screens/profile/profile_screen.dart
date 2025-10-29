import 'package:flutter/material.dart';
import 'dart:io';
import '../../../service/auth_service.dart';
import '../../../models/user.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  void _refreshProfile() {
    if (mounted) setState(() {});
  }

  // Helper untuk menentukan ImageProvider secara defensif
  ImageProvider<Object>? _getProfileImageProvider(String? path) {
    if (path == null) return null;
    if (path.startsWith('assets/')) return AssetImage(path);
    try {
      if (File(path).existsSync()) return FileImage(File(path));
    } catch (_) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Center(child: Text("Terjadi kesalahan. Silakan login ulang."));
    }

    final ImageProvider<Object>? profileImageProvider =
        _getProfileImageProvider(user.profileImageUrl);
    final bool hasProfileImage = profileImageProvider != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFIL ---
            _buildCustomHeader(
              context,
              user: user,
              profileImageProvider: profileImageProvider,
              hasProfileImage: hasProfileImage,
            ),

            // --- BODY INFORMASI PROFIL ---
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAMA
                    _buildProfileDetail(
                        label: "Nama Lengkap",
                        value: user.name,
                        isBold: true),
                    const Divider(height: 30),

                    // TANGGAL LAHIR
                    _buildProfileDetail(
                        label: "Tanggal Lahir",
                        value: user.formattedDateOfBirth),
                    const Divider(height: 30),

                    // JENIS KELAMIN
                    _buildProfileDetail(
                        label: "Jenis Kelamin",
                        value: user.gender ?? 'Belum diatur'),
                    const Divider(height: 30),

                    // EMAIL
                    _buildProfileDetail(
                        label: "Email", value: user.email),
                    const Divider(height: 30),

                    // ASAL
                    _buildProfileDetail(
                        label: "Asal", value: user.origin ?? 'Belum diatur'),

                    const SizedBox(height: 10),
                    // Tombol Edit
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const EditProfileScreen(),
                            ),
                          );
                          _refreshProfile();
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text(
                          "Edit Detail Profil",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header tanpa tombol setting
  Widget _buildCustomHeader(BuildContext context,
      {User? user,
      required ImageProvider<Object>? profileImageProvider,
      required bool hasProfileImage}) {
    return Container(
      padding:
          const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(25)),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bar atas hanya dengan tombol back
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Avatar
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.5),
                backgroundImage: profileImageProvider,
                child: hasProfileImage
                    ? null
                    : const Icon(Icons.person,
                        size: 30, color: Colors.white),
              ),
              // Tombol Back
              IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            "Halo, ${user?.name.split(' ').first ?? 'User'}!",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "Selamat datang di ExpenseBULL",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk detail profil
  Widget _buildProfileDetail(
      {required String label,
      required String value,
      bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight:
                isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.black87 : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
