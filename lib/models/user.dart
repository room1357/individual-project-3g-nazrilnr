// lib/models/user.dart
class User {
  final String uid;
  final String email;
  String name; 
  String? origin;
  String? gender;
  DateTime? dateOfBirth;

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.origin,
    this.gender,
    this.dateOfBirth,
  });
  
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return 'Belum diatur';
    return '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}';
  }
}