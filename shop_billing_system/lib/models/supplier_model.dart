class Supplier {
  final String id;
  final String name;
  final String companyName;
  final String phone;
  final String email;
  final String address;
  final double currentBalance; // Positive = shop owes money to supplier (payable)
  final String notes;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    this.companyName = '',
    this.phone = '',
    this.email = '',
    this.address = '',
    this.currentBalance = 0.0,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Supplier.fromMap(String key, Map<dynamic, dynamic> map) {
    return Supplier(
      id: key,
      name: map['name']?.toString() ?? 'Unnamed Supplier',
      companyName: map['companyName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString() ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'companyName': companyName,
      'phone': phone,
      'email': email,
      'address': address,
      'currentBalance': currentBalance,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
