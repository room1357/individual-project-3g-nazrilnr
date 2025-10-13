class Expense {
  final String id;
  final String title;
  final double amount;
  
  final String ownerId; // Siapa yang membayar/mencatat
  final List<String> participantIds; // Daftar ID user yang berbagi biaya
  
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.ownerId,
    required this.participantIds,
    required this.category,
    required this.date,
    required this.description,
  });

  // --- JSON DESERIALIZATION (Dari JSON ke Objek Dart) ---
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as double,
      ownerId: json['ownerId'] as String,
      // Konversi List<dynamic> dari JSON menjadi List<String>
      participantIds: List<String>.from(json['participantIds'] as List), 
      category: json['category'] as String,
      // Konversi string kembali ke DateTime
      date: DateTime.parse(json['date'] as String), 
      description: json['description'] as String,
    );
  }

  // --- JSON SERIALIZATION (Dari Objek Dart ke JSON Map) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'ownerId': ownerId,
      'participantIds': participantIds,
      'category': category,
      'date': date.toIso8601String(), // Simpan DateTime sebagai string ISO
      'description': description,
    };
  }
}