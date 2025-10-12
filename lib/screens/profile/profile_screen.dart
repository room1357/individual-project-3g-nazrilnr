import 'package:flutter/material.dart';
import '../../../service/auth_service.dart'; // Import AuthService
import 'edit_profile_screen.dart'; // Import layar Edit

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Gunakan instance AuthService
  final AuthService _authService = AuthService();

  // Metode untuk memicu rebuild setelah kembali dari layar edit
  void _refreshProfile() {
    setState(() {
      // Hanya memanggil setState untuk me-rebuild widget dengan data terbaru dari AuthService
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    // Menangani kasus jika user belum login (seharusnya tidak terjadi jika navigasi benar)
    if (user == null) {
      return const Center(child: Text("Terjadi kesalahan. Silakan login ulang."));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Foto profil (dengan InkWell untuk edit/navigasi)
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );
                  // Panggil refresh setelah kembali dari EditScreen
                  _refreshProfile();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: const AssetImage("assets/images/profil.jpg"),
                ),
              ),
              const SizedBox(height: 25),

              // Kartu Informasi Profil
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
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
                        value: user.dateOfBirth?.toIso8601String().split('T')[0] ?? 'Belum diatur'),
                    const Divider(height: 30),

                    // JENIS KELAMIN
                    _buildProfileDetail(
                        label: "Jenis Kelamin",
                        value: user.gender ?? 'Belum diatur'),
                    const Divider(height: 30),

                    // EMAIL
                    _buildProfileDetail(
                        label: "Email",
                        value: user.email),
                    const Divider(height: 30),

                    // ASAL
                    _buildProfileDetail(
                        label: "Asal",
                        value: user.origin ?? 'Belum diatur'),
                        
                    const SizedBox(height: 10),
                    // Tombol Edit di bagian bawah kartu
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                          _refreshProfile();
                        },
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Edit Profil", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget untuk membuat baris detail profil
  Widget _buildProfileDetail({required String label, required String value, bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.black87 : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}