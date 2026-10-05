class Expense {
  final String id;
  final String category; // Rent, Electricity, Salaries, Transport, Supplies, Maintenance, Other
  final double amount;
  final DateTime date;
  final String description;
  final String paymentMethod;
  final String createdBy;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
    this.paymentMethod = 'Cash',
    this.createdBy = 'Admin',
  });

  factory Expense.fromMap(String key, Map<dynamic, dynamic> map) {
    return Expense(
      id: key,
      category: map['category']?.toString() ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      description: map['description']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'paymentMethod': paymentMethod,
      'createdBy': createdBy,
    };
  }
}
