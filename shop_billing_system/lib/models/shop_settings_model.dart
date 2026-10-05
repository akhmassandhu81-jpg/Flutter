class ShopSettings {
  final String shopName;
  final String address;
  final String phone;
  final String email;
  final String taxNumber;
  final String currencySymbol;
  final double defaultTaxRate;
  final int defaultMinStockLevel;
  final String receiptFooterNote;

  ShopSettings({
    this.shopName = 'Jinnah Super Market',
    this.address = 'Islamabad, Pakistan',
    this.phone = '051-111-6328',
    this.email = 'info@jinnahmarket.pk',
    this.taxNumber = 'STRN-123456789',
    this.currencySymbol = 'Rs',
    this.defaultTaxRate = 0.0,
    this.defaultMinStockLevel = 5,
    this.receiptFooterNote = 'NO RETURN NO EXCHANGE WITHOUT RECEIPT\nThank you for shopping with us!',
  });

  factory ShopSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return ShopSettings();
    return ShopSettings(
      shopName: map['shopName']?.toString() ?? 'Jinnah Super Market',
      address: map['address']?.toString() ?? 'Islamabad, Pakistan',
      phone: map['phone']?.toString() ?? '051-111-6328',
      email: map['email']?.toString() ?? 'info@jinnahmarket.pk',
      taxNumber: map['taxNumber']?.toString() ?? 'STRN-123456789',
      currencySymbol: map['currencySymbol']?.toString() ?? 'Rs',
      defaultTaxRate: (map['defaultTaxRate'] as num?)?.toDouble() ?? 0.0,
      defaultMinStockLevel: (map['defaultMinStockLevel'] as num?)?.toInt() ?? 5,
      receiptFooterNote: map['receiptFooterNote']?.toString() ??
          'NO RETURN NO EXCHANGE WITHOUT RECEIPT\nThank you for shopping with us!',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'address': address,
      'phone': phone,
      'email': email,
      'taxNumber': taxNumber,
      'currencySymbol': currencySymbol,
      'defaultTaxRate': defaultTaxRate,
      'defaultMinStockLevel': defaultMinStockLevel,
      'receiptFooterNote': receiptFooterNote,
    };
  }
}
