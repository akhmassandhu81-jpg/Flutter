class InventoryMovement {
  final String id;
  final String productId;
  final String productName;
  final int previousStock;
  final int changeQuantity; // Positive for additions, negative for deductions
  final int newStock;
  final String reason; // Purchase, Sale, Sale Return, Damage, Restock, Expiry, Manual Adjustment
  final String referenceId; // Sale ID, Purchase ID, etc.
  final String operatorName;
  final DateTime timestamp;

  InventoryMovement({
    required this.id,
    required this.productId,
    required this.productName,
    required this.previousStock,
    required this.changeQuantity,
    required this.newStock,
    required this.reason,
    this.referenceId = '',
    this.operatorName = 'Admin',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory InventoryMovement.fromMap(String key, Map<dynamic, dynamic> map) {
    return InventoryMovement(
      id: key,
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? 'Unknown Product',
      previousStock: (map['previousStock'] as num?)?.toInt() ?? 0,
      changeQuantity: (map['changeQuantity'] as num?)?.toInt() ?? 0,
      newStock: (map['newStock'] as num?)?.toInt() ?? 0,
      reason: map['reason']?.toString() ?? 'Manual Adjustment',
      referenceId: map['referenceId']?.toString() ?? '',
      operatorName: map['operatorName']?.toString() ?? 'Admin',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'previousStock': previousStock,
      'changeQuantity': changeQuantity,
      'newStock': newStock,
      'reason': reason,
      'referenceId': referenceId,
      'operatorName': operatorName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
