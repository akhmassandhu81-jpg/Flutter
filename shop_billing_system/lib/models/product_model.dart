class Product {
  final String id;
  final String name;
  final String sku;
  final String barcode;
  final String categoryId;
  final String categoryName;
  final String brand;
  final String description;
  final double purchasePrice;
  final double sellingPrice;
  final int stock;
  final int minStock;
  final String unit;
  final String supplierId;
  final String imageUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    this.sku = '',
    this.barcode = '',
    this.categoryId = '',
    this.categoryName = 'General',
    this.brand = '',
    this.description = '',
    this.purchasePrice = 0.0,
    required this.sellingPrice,
    this.stock = 0,
    this.minStock = 5,
    this.unit = 'Pcs',
    this.supplierId = '',
    this.imageUrl = '',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isLowStock => stock <= minStock && stock > 0;
  bool get isOutOfStock => stock <= 0;

  factory Product.fromMap(String key, Map<dynamic, dynamic> map) {
    // Gracefully handle legacy data structure where price was selling price and stock might be missing
    double sellingPrice = 0.0;
    if (map['sellingPrice'] != null) {
      sellingPrice = (map['sellingPrice'] as num).toDouble();
    } else if (map['price'] != null) {
      sellingPrice = (map['price'] as num).toDouble();
    }

    double purchasePrice = 0.0;
    if (map['purchasePrice'] != null) {
      purchasePrice = (map['purchasePrice'] as num).toDouble();
    }

    return Product(
      id: key,
      name: map['name']?.toString() ?? 'Unnamed Product',
      sku: map['sku']?.toString() ?? '',
      barcode: map['barcode']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? 'General',
      brand: map['brand']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      stock: (map['stock'] as num?)?.toInt() ?? (map['quantity'] as num?)?.toInt() ?? 10,
      minStock: (map['minStock'] as num?)?.toInt() ?? 5,
      unit: map['unit']?.toString() ?? 'Pcs',
      supplierId: map['supplierId']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'description': description,
      'purchasePrice': purchasePrice,
      'sellingPrice': sellingPrice,
      'price': sellingPrice, // Legacy compatibility
      'stock': stock,
      'minStock': minStock,
      'unit': unit,
      'supplierId': supplierId,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? sku,
    String? barcode,
    String? categoryId,
    String? categoryName,
    String? brand,
    String? description,
    double? purchasePrice,
    double? sellingPrice,
    int? stock,
    int? minStock,
    String? unit,
    String? supplierId,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      unit: unit ?? this.unit,
      supplierId: supplierId ?? this.supplierId,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
