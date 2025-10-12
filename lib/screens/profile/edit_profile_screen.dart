import 'package:flutter/material.dart';
import '../../../service/auth_service.dart';
import '../../../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  // Data user diinisialisasi dari service
  late User _currentUser;
  late TextEditingController _nameController;
  late TextEditingController _originController;
  
  String? _selectedGender;
  late DateTime _selectedDateOfBirth;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser!;
    
    _nameController = TextEditingController(text: _currentUser.name);
    _originController = TextEditingController(text: _currentUser.origin ?? '');
    _selectedGender = _currentUser.gender;
    // Gunakan tanggal saat ini jika tanggal lahir belum diatur
    _selectedDateOfBirth = _currentUser.dateOfBirth ?? DateTime(2000, 1, 1);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    super.dispose();
  }

  // Helper untuk memilih tanggal lahir
  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // Metode untuk menyimpan perubahan profil
  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    final errorMessage = await _authService.updateProfile(
      name: _nameController.text,
      origin: _originController.text,
      gender: _selectedGender!,
      dateOfBirth: _selectedDateOfBirth,
    );

    setState(() { _isLoading = false; });

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $errorMessage')),
      );
    }
  }
  
  // Metode Helper untuk styling input field (Konsisten dengan Project 1)
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      // Styling fokus, error, dll.
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Edit Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Field Nama Lengkap
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Nama Lengkap"),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Field Email (Read-only)
              TextFormField(
                initialValue: _currentUser.email,
                decoration: _inputDecoration("Email (Tidak dapat diubah)"),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Field Asal
              TextFormField(
                controller: _originController,
                decoration: _inputDecoration("Asal"),
                validator: (value) => value!.isEmpty ? 'Asal tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),

              // Field Jenis Kelamin
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: _inputDecoration("Jenis Kelamin"),
                items: ['Laki-laki', 'Perempuan']
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() { _selectedGender = value; });
                },
                validator: (value) => value == null ? 'Pilih jenis kelamin' : null,
              ),
              const SizedBox(height: 16),

              // Field Tanggal Lahir
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tanggal Lahir: ${_currentUser.formattedDateOfBirth}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}