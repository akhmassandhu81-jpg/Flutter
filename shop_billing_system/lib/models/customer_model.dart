class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final double currentBalance; // Positive = customer owes money (receivable)
  final double totalPurchases;
  final DateTime? lastPurchaseDate;
  final String notes;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
    this.currentBalance = 0.0,
    this.totalPurchases = 0.0,
    this.lastPurchaseDate,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Customer.fromMap(String key, Map<dynamic, dynamic> map) {
    return Customer(
      id: key,
      name: map['name']?.toString() ?? 'Unnamed Customer',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (map['totalPurchases'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseDate: map['lastPurchaseDate'] != null
          ? DateTime.tryParse(map['lastPurchaseDate'].toString())
          : null,
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'currentBalance': currentBalance,
      'totalPurchases': totalPurchases,
      'lastPurchaseDate': lastPurchaseDate?.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
