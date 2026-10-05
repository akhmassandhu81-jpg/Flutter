class PurchaseItem {
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final double total;

  PurchaseItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    double? total,
  }) : total = total ?? (unitPrice * quantity);

  factory PurchaseItem.fromMap(Map<dynamic, dynamic> map) {
    double price = (map['unitPrice'] as num?)?.toDouble() ?? (map['price'] as num?)?.toDouble() ?? 0.0;
    int qty = (map['quantity'] as num?)?.toInt() ?? 1;

    return PurchaseItem(
      productId: map['productId']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Product',
      unitPrice: price,
      quantity: qty,
      total: (map['total'] as num?)?.toDouble() ?? (price * qty),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'total': total,
    };
  }
}

class Purchase {
  final String id;
  final String purchaseInvoiceNumber;
  final DateTime date;
  final String supplierId;
  final String supplierName;
  final List<PurchaseItem> items;
  final double totalAmount;
  final double paidAmount;
  final double remainingBalance;
  final String paymentStatus; // Paid, Partial, Pending
  final String notes;
  final String createdBy;

  Purchase({
    required this.id,
    required this.purchaseInvoiceNumber,
    required this.date,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.remainingBalance = 0.0,
    this.paymentStatus = 'Paid',
    this.notes = '',
    this.createdBy = 'Admin',
  });

  factory Purchase.fromMap(String key, Map<dynamic, dynamic> map) {
    List<PurchaseItem> items = [];
    if (map['items'] != null && map['items'] is List) {
      for (var p in (map['items'] as List)) {
        if (p is Map) {
          items.add(PurchaseItem.fromMap(p));
        }
      }
    }

    double total = (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
    double paid = (map['paidAmount'] as num?)?.toDouble() ?? total;

    return Purchase(
      id: key,
      purchaseInvoiceNumber: map['purchaseInvoiceNumber']?.toString() ?? 'PUR-${key.substring(0, 5)}',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      supplierId: map['supplierId']?.toString() ?? '',
      supplierName: map['supplierName']?.toString() ?? 'General Supplier',
      items: items,
      totalAmount: total,
      paidAmount: paid,
      remainingBalance: (map['remainingBalance'] as num?)?.toDouble() ?? (total - paid),
      paymentStatus: map['paymentStatus']?.toString() ?? (paid >= total ? 'Paid' : (paid > 0 ? 'Partial' : 'Pending')),
      notes: map['notes']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purchaseInvoiceNumber': purchaseInvoiceNumber,
      'date': date.toIso8601String(),
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'remainingBalance': remainingBalance,
      'paymentStatus': paymentStatus,
      'notes': notes,
      'createdBy': createdBy,
    };
  }
}
