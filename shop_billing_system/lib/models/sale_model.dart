class SaleItem {
  final String productId;
  final String name;
  final String sku;
  final double price;
  final double purchasePrice;
  final int quantity;
  final double discount;
  final double total;

  SaleItem({
    required this.productId,
    required this.name,
    this.sku = '',
    required this.price,
    this.purchasePrice = 0.0,
    required this.quantity,
    this.discount = 0.0,
    double? total,
  }) : total = total ?? ((price * quantity) - discount);

  factory SaleItem.fromMap(Map<dynamic, dynamic> map) {
    double price = (map['price'] as num?)?.toDouble() ?? 0.0;
    int qty = (map['quantity'] as num?)?.toInt() ?? 1;
    double discount = (map['discount'] as num?)?.toDouble() ?? 0.0;

    return SaleItem(
      productId: map['productId']?.toString() ?? map['key']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unknown Product',
      sku: map['sku']?.toString() ?? '',
      price: price,
      purchasePrice: (map['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      quantity: qty,
      discount: discount,
      total: (map['total'] as num?)?.toDouble() ?? ((price * qty) - discount),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'sku': sku,
      'price': price,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'discount': discount,
      'total': total,
    };
  }
}

class Sale {
  final String id;
  final String invoiceNumber;
  final DateTime date;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final List<SaleItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;
  final double remainingBalance;
  final String paymentMethod; // Cash, Card, Bank, Credit
  final String status; // Completed, Returned, Cancelled
  final String notes;
  final String createdBy;

  Sale({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    this.customerId = '',
    this.customerName = 'Walk-in Customer',
    this.customerPhone = '',
    required this.items,
    required this.subtotal,
    this.discount = 0.0,
    this.tax = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.changeAmount = 0.0,
    this.remainingBalance = 0.0,
    this.paymentMethod = 'Cash',
    this.status = 'Completed',
    this.notes = '',
    this.createdBy = 'Admin',
  });

  // Calculate gross profit for this sale
  double get totalCost => items.fold(0.0, (sum, item) => sum + (item.purchasePrice * item.quantity));
  double get grossProfit => totalAmount - totalCost;

  Sale copyWith({
    String? id,
    String? invoiceNumber,
    DateTime? date,
    String? customerId,
    String? customerName,
    String? customerPhone,
    List<SaleItem>? items,
    double? subtotal,
    double? discount,
    double? tax,
    double? totalAmount,
    double? paidAmount,
    double? changeAmount,
    double? remainingBalance,
    String? paymentMethod,
    String? status,
    String? notes,
    String? createdBy,
  }) {
    return Sale(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      date: date ?? this.date,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  factory Sale.fromMap(String key, Map<dynamic, dynamic> map) {
    // Handle legacy sales structure
    List<SaleItem> items = [];
    if (map['products'] != null && map['products'] is List) {
      for (var p in (map['products'] as List)) {
        if (p is Map) {
          items.add(SaleItem.fromMap(p));
        }
      }
    } else if (map['items'] != null && map['items'] is List) {
      for (var p in (map['items'] as List)) {
        if (p is Map) {
          items.add(SaleItem.fromMap(p));
        }
      }
    }

    double totalAmount = (map['totalAmount'] as num?)?.toDouble() ?? 0.0;
    double paid = (map['paidAmount'] as num?)?.toDouble() ?? totalAmount;

    DateTime saleDate = DateTime.now();
    if (map['date'] != null) {
      saleDate = DateTime.tryParse(map['date'].toString()) ?? DateTime.now();
    }

    String invoiceNum = map['invoiceNumber']?.toString() ??
        'INV-${saleDate.millisecondsSinceEpoch.toString().substring(5)}';

    return Sale(
      id: key,
      invoiceNumber: invoiceNum,
      date: saleDate,
      customerId: map['customerId']?.toString() ?? '',
      customerName: map['customerName']?.toString() ?? 'Walk-in Customer',
      customerPhone: map['customerPhone']?.toString() ?? '',
      items: items,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? totalAmount,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      totalAmount: totalAmount,
      paidAmount: paid,
      changeAmount: (map['changeAmount'] as num?)?.toDouble() ?? (paid > totalAmount ? paid - totalAmount : 0.0),
      remainingBalance: (map['remainingBalance'] as num?)?.toDouble() ?? (totalAmount > paid ? totalAmount - paid : 0.0),
      paymentMethod: map['paymentMethod']?.toString() ?? 'Cash',
      status: map['status']?.toString() ?? 'Completed',
      notes: map['notes']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? 'Admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'date': date.toIso8601String(),
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((i) => i.toMap()).toList(),
      'products': items.map((i) => i.toMap()).toList(), // Legacy field
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'changeAmount': changeAmount,
      'remainingBalance': remainingBalance,
      'paymentMethod': paymentMethod,
      'status': status,
      'notes': notes,
      'createdBy': createdBy,
    };
  }
}
