class AuditLog {
  final String id;
  final String user;
  final String action; // e.g. "Product Created", "Stock Adjusted", "Sale Completed"
  final String details;
  final String module; // Products, POS, Inventory, Expense, etc.
  final DateTime timestamp;

  AuditLog({
    required this.id,
    required this.user,
    required this.action,
    required this.details,
    required this.module,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AuditLog.fromMap(String key, Map<dynamic, dynamic> map) {
    return AuditLog(
      id: key,
      user: map['user']?.toString() ?? 'Admin',
      action: map['action']?.toString() ?? 'System Action',
      details: map['details']?.toString() ?? '',
      module: map['module']?.toString() ?? 'General',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'action': action,
      'details': details,
      'module': module,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
