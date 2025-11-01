class Expense {
  final String id;
  final String title;
  final double amount;
  final String ownerId;
  final List<String> participantIds;
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

  // copyWith untuk membuat salinan dengan beberapa field diubah
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? ownerId,
    List<String>? participantIds,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      ownerId: ownerId ?? this.ownerId,
      participantIds: participantIds ?? List.from(this.participantIds),
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  // --- dari JSON ke objek ---
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      ownerId: json['ownerId'] as String,
      participantIds: List<String>.from(json['participantIds'] as List),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
    );
  }

  // --- dari objek ke JSON ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'ownerId': ownerId,
      'participantIds': participantIds,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}
