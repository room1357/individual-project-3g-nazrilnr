class User {
  final String uid;
  final String email;
  String name; // Non-final untuk diupdate
  String? origin;
  String? gender;
  DateTime? dateOfBirth;
  String? profileImageUrl; // Jalur/URL Foto Profil
  final String role; // Role: 'admin' atau 'user'

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.origin,
    this.gender,
    this.dateOfBirth,
    this.profileImageUrl,
    required this.role,
  });

  // Helper untuk menampilkan tanggal lahir (digunakan di UI)
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'Belum diatur';
    return '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';
  }
}