import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/services/sqlite_database_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/sale_model.dart';
import '../models/purchase_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/expense_model.dart';
import '../models/inventory_movement_model.dart';
import '../models/audit_log_model.dart';
import '../models/shop_settings_model.dart';

class ShopRepository {
  static final ShopRepository _instance = ShopRepository._internal();
  factory ShopRepository() => _instance;
  ShopRepository._internal();

  final SqliteDatabaseService _sqlite = SqliteDatabaseService();

  // Stream controllers for reactive SQLite updates
  final StreamController<List<Product>> _productController = StreamController<List<Product>>.broadcast();
  final StreamController<List<Category>> _categoryController = StreamController<List<Category>>.broadcast();
  final StreamController<List<Customer>> _customerController = StreamController<List<Customer>>.broadcast();
  final StreamController<List<Supplier>> _supplierController = StreamController<List<Supplier>>.broadcast();
  final StreamController<List<Purchase>> _purchaseController = StreamController<List<Purchase>>.broadcast();
  final StreamController<List<Sale>> _saleController = StreamController<List<Sale>>.broadcast();
  final StreamController<List<Expense>> _expenseController = StreamController<List<Expense>>.broadcast();
  final StreamController<List<InventoryMovement>> _movementController = StreamController<List<InventoryMovement>>.broadcast();
  final StreamController<List<AuditLog>> _auditController = StreamController<List<AuditLog>>.broadcast();
  final StreamController<ShopSettings> _settingsController = StreamController<ShopSettings>.broadcast();

  // --- PRODUCTS (SQLITE) ---
  Stream<List<Product>> get productsStream async* {
    yield await getProducts();
    yield* _productController.stream;
  }

  Future<List<Product>> getProducts() async {
    final db = await _sqlite.database;
    final maps = await db.query('products', orderBy: 'created_at DESC');
    if (maps.isEmpty) {
      await _seedDefaultData(db);
      final seededMaps = await db.query('products', orderBy: 'created_at DESC');
      return seededMaps.map(_productFromSqlMap).toList();
    }
    return maps.map(_productFromSqlMap).toList();
  }

  Product _productFromSqlMap(Map<String, dynamic> map) {
    return Product(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',
      barcode: map['barcode']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name']?.toString() ?? 'General',
      brand: map['brand']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      minStock: (map['min_stock'] as num?)?.toInt() ?? 5,
      unit: map['unit']?.toString() ?? 'Pcs',
      supplierId: map['supplier_id']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> _productToSqlMap(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'sku': product.sku,
      'barcode': product.barcode,
      'category_id': product.categoryId.isEmpty ? null : product.categoryId,
      'category_name': product.categoryName,
      'brand': product.brand,
      'description': product.description,
      'purchase_price': product.purchasePrice,
      'selling_price': product.sellingPrice,
      'stock': product.stock,
      'min_stock': product.minStock,
      'unit': product.unit,
      'supplier_id': product.supplierId.isEmpty ? null : product.supplierId,
      'image_url': product.imageUrl,
      'is_active': product.isActive ? 1 : 0,
      'created_at': product.createdAt.toIso8601String(),
      'updated_at': product.updatedAt.toIso8601String(),
    };
  }

  Future<void> addProduct(Product product) async {
    final db = await _sqlite.database;
    await db.insert('products', _productToSqlMap(product), conflictAlgorithm: ConflictAlgorithm.replace);
    await logAudit(
      action: 'Product Created',
      details: 'Added product "${product.name}" with selling price Rs ${product.sellingPrice}',
      module: 'Products',
    );
    _productController.add(await getProducts());
  }

  Future<void> updateProduct(Product product) async {
    final db = await _sqlite.database;
    await db.update('products', _productToSqlMap(product), where: 'id = ?', whereArgs: [product.id]);
    _productController.add(await getProducts());
  }

  Future<void> deleteProduct(String productId, String productName) async {
    final db = await _sqlite.database;
    await db.delete('products', where: 'id = ?', whereArgs: [productId]);
    await logAudit(
      action: 'Product Deleted',
      details: 'Removed product "$productName" (ID: $productId)',
      module: 'Products',
    );
    _productController.add(await getProducts());
  }

  Future<void> adjustStock({
    required Product product,
    required int newQuantity,
    required String reason,
    String operatorName = 'Admin',
  }) async {
    final int previousStock = product.stock;
    final int change = newQuantity - previousStock;
    if (change == 0) return;

    final updated = product.copyWith(stock: newQuantity, updatedAt: DateTime.now());
    await updateProduct(updated);

    final movement = InventoryMovement(
      id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      productName: product.name,
      previousStock: previousStock,
      changeQuantity: change,
      newStock: newQuantity,
      reason: reason,
      operatorName: operatorName,
    );

    final db = await _sqlite.database;
    await db.insert('inventory_movements', {
      'id': movement.id,
      'product_id': movement.productId,
      'product_name': movement.productName,
      'previous_stock': movement.previousStock,
      'change_quantity': movement.changeQuantity,
      'new_stock': movement.newStock,
      'reason': movement.reason,
      'reference_id': movement.referenceId,
      'operator_name': movement.operatorName,
      'timestamp': movement.timestamp.toIso8601String(),
    });
    _movementController.add(await getInventoryMovements());
  }

  // --- CATEGORIES (SQLITE) ---
  Stream<List<Category>> get categoriesStream async* {
    yield await getCategories();
    yield* _categoryController.stream;
  }

  Future<List<Category>> getCategories() async {
    final db = await _sqlite.database;
    final maps = await db.query('categories', orderBy: 'name ASC');
    if (maps.isEmpty) {
      await _seedDefaultData(db);
      final seededMaps = await db.query('categories', orderBy: 'name ASC');
      return seededMaps.map(_categoryFromSqlMap).toList();
    }
    return maps.map(_categoryFromSqlMap).toList();
  }

  Category _categoryFromSqlMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      iconName: map['icon_name']?.toString() ?? 'category',
      isActive: (map['is_active'] as int?) == 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> _categoryToSqlMap(Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'description': category.description,
      'icon_name': category.iconName,
      'is_active': category.isActive ? 1 : 0,
      'created_at': category.createdAt.toIso8601String(),
    };
  }

  Future<void> addCategory(Category category) async {
    final db = await _sqlite.database;
    await db.insert('categories', _categoryToSqlMap(category), conflictAlgorithm: ConflictAlgorithm.replace);
    _categoryController.add(await getCategories());
  }

  Future<void> updateCategory(Category category) async {
    final db = await _sqlite.database;
    await db.update('categories', _categoryToSqlMap(category), where: 'id = ?', whereArgs: [category.id]);
    _categoryController.add(await getCategories());
  }

  Future<void> deleteCategory(String categoryId, String categoryName) async {
    final db = await _sqlite.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [categoryId]);
    _categoryController.add(await getCategories());
  }

  // --- CUSTOMERS (SQLITE) ---
  Stream<List<Customer>> get customersStream async* {
    yield await getCustomers();
    yield* _customerController.stream;
  }

  Future<List<Customer>> getCustomers() async {
    final db = await _sqlite.database;
    final maps = await db.query('customers', orderBy: 'name ASC');
    if (maps.isEmpty) {
      await _seedDefaultCustomerAndSupplier(db);
      final seededMaps = await db.query('customers', orderBy: 'name ASC');
      return seededMaps.map(_customerFromSqlMap).toList();
    }
    return maps.map(_customerFromSqlMap).toList();
  }

  Customer _customerFromSqlMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      totalPurchases: (map['total_purchases'] as num?)?.toDouble() ?? 0.0,
      lastPurchaseDate: map['last_purchase_date'] != null ? DateTime.tryParse(map['last_purchase_date'].toString()) : null,
      notes: map['notes']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> _customerToSqlMap(Customer customer) {
    return {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
      'email': customer.email,
      'address': customer.address,
      'current_balance': customer.currentBalance,
      'total_purchases': customer.totalPurchases,
      'last_purchase_date': customer.lastPurchaseDate?.toIso8601String(),
      'notes': customer.notes,
      'created_at': customer.createdAt.toIso8601String(),
    };
  }

  Future<void> addCustomer(Customer customer) async {
    final db = await _sqlite.database;
    await db.insert('customers', _customerToSqlMap(customer), conflictAlgorithm: ConflictAlgorithm.replace);
    _customerController.add(await getCustomers());
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await _sqlite.database;
    await db.update('customers', _customerToSqlMap(customer), where: 'id = ?', whereArgs: [customer.id]);
    _customerController.add(await getCustomers());
  }

  Future<void> recordCustomerPayment({
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required String notes,
  }) async {
    final db = await _sqlite.database;
    final maps = await db.query('customers', where: 'id = ?', whereArgs: [customerId]);
    if (maps.isNotEmpty) {
      final c = _customerFromSqlMap(maps.first);
      final newBal = (c.currentBalance - amount).clamp(0.0, double.infinity);
      final updated = Customer(
        id: c.id,
        name: c.name,
        phone: c.phone,
        email: c.email,
        address: c.address,
        currentBalance: newBal,
        totalPurchases: c.totalPurchases,
        lastPurchaseDate: c.lastPurchaseDate,
        notes: c.notes,
        createdAt: c.createdAt,
      );
      await db.update('customers', _customerToSqlMap(updated), where: 'id = ?', whereArgs: [customerId]);
      _customerController.add(await getCustomers());
    }
  }

  // --- SUPPLIERS (SQLITE) ---
  Stream<List<Supplier>> get suppliersStream async* {
    yield await getSuppliers();
    yield* _supplierController.stream;
  }

  Future<List<Supplier>> getSuppliers() async {
    final db = await _sqlite.database;
    final maps = await db.query('suppliers', orderBy: 'name ASC');
    if (maps.isEmpty) {
      await _seedDefaultCustomerAndSupplier(db);
      final seededMaps = await db.query('suppliers', orderBy: 'name ASC');
      return seededMaps.map(_supplierFromSqlMap).toList();
    }
    return maps.map(_supplierFromSqlMap).toList();
  }

  Supplier _supplierFromSqlMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString() ?? '',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> _supplierToSqlMap(Supplier supplier) {
    return {
      'id': supplier.id,
      'name': supplier.name,
      'company_name': supplier.companyName,
      'phone': supplier.phone,
      'email': supplier.email,
      'address': supplier.address,
      'current_balance': supplier.currentBalance,
      'notes': supplier.notes,
      'created_at': supplier.createdAt.toIso8601String(),
    };
  }

  Future<void> addSupplier(Supplier supplier) async {
    final db = await _sqlite.database;
    await db.insert('suppliers', _supplierToSqlMap(supplier), conflictAlgorithm: ConflictAlgorithm.replace);
    _supplierController.add(await getSuppliers());
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final db = await _sqlite.database;
    await db.update('suppliers', _supplierToSqlMap(supplier), where: 'id = ?', whereArgs: [supplier.id]);
    _supplierController.add(await getSuppliers());
  }

  Future<void> recordSupplierPayment({
    required String supplierId,
    required String supplierName,
    required double amount,
    required String paymentMethod,
    required String notes,
  }) async {
    final db = await _sqlite.database;
    final maps = await db.query('suppliers', where: 'id = ?', whereArgs: [supplierId]);
    if (maps.isNotEmpty) {
      final s = _supplierFromSqlMap(maps.first);
      final newBal = (s.currentBalance - amount).clamp(0.0, double.infinity);
      final updated = Supplier(
        id: s.id,
        name: s.name,
        companyName: s.companyName,
        phone: s.phone,
        email: s.email,
        address: s.address,
        currentBalance: newBal,
        notes: s.notes,
        createdAt: s.createdAt,
      );
      await db.update('suppliers', _supplierToSqlMap(updated), where: 'id = ?', whereArgs: [supplierId]);
      _supplierController.add(await getSuppliers());
    }
  }

  // --- PURCHASES (SQLITE) ---
  Stream<List<Purchase>> get purchasesStream async* {
    yield await getPurchases();
    yield* _purchaseController.stream;
  }

  Future<List<Purchase>> getPurchases() async {
    final db = await _sqlite.database;
    final purchaseMaps = await db.query('purchases', orderBy: 'date DESC');
    List<Purchase> purchases = [];

    for (var pMap in purchaseMaps) {
      final pId = pMap['id'].toString();
      final itemMaps = await db.query('purchase_items', where: 'purchase_id = ?', whereArgs: [pId]);
      List<PurchaseItem> items = itemMaps.map((iMap) {
        return PurchaseItem(
          productId: iMap['product_id']?.toString() ?? '',
          name: iMap['name']?.toString() ?? '',
          unitPrice: (iMap['unit_price'] as num?)?.toDouble() ?? 0.0,
          quantity: (iMap['quantity'] as num?)?.toInt() ?? 1,
          total: (iMap['total'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      purchases.add(Purchase(
        id: pId,
        purchaseInvoiceNumber: pMap['purchase_invoice_number']?.toString() ?? '',
        date: pMap['date'] != null ? DateTime.tryParse(pMap['date'].toString()) ?? DateTime.now() : DateTime.now(),
        supplierId: pMap['supplier_id']?.toString() ?? '',
        supplierName: pMap['supplier_name']?.toString() ?? '',
        items: items,
        totalAmount: (pMap['total_amount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (pMap['paid_amount'] as num?)?.toDouble() ?? 0.0,
        remainingBalance: (pMap['remaining_balance'] as num?)?.toDouble() ?? 0.0,
        paymentStatus: pMap['payment_status']?.toString() ?? 'Paid',
        notes: pMap['notes']?.toString() ?? '',
        createdBy: pMap['created_by']?.toString() ?? 'Admin',
      ));
    }
    return purchases;
  }

  Future<void> addPurchase({
    required Purchase purchase,
    required List<Product> currentProducts,
  }) async {
    final pKey = purchase.id.isNotEmpty ? purchase.id : 'pur_${DateTime.now().millisecondsSinceEpoch}';

    await _sqlite.transaction((txn) async {
      await txn.insert('purchases', {
        'id': pKey,
        'purchase_invoice_number': purchase.purchaseInvoiceNumber,
        'date': purchase.date.toIso8601String(),
        'supplier_id': purchase.supplierId.isEmpty ? null : purchase.supplierId,
        'supplier_name': purchase.supplierName,
        'total_amount': purchase.totalAmount,
        'paid_amount': purchase.paidAmount,
        'remaining_balance': purchase.remainingBalance,
        'payment_status': purchase.paymentStatus,
        'notes': purchase.notes,
        'created_by': purchase.createdBy,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (var item in purchase.items) {
        await txn.insert('purchase_items', {
          'purchase_id': pKey,
          'product_id': item.productId,
          'name': item.name,
          'unit_price': item.unitPrice,
          'quantity': item.quantity,
          'total': item.total,
        });

        final prdMaps = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        if (prdMaps.isNotEmpty) {
          final curStock = (prdMaps.first['stock'] as num?)?.toInt() ?? 0;
          final newStock = curStock + item.quantity;
          final prdName = prdMaps.first['name']?.toString() ?? item.name;

          await txn.update(
            'products',
            {'stock': newStock, 'purchase_price': item.unitPrice, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          final movId = 'mov_${DateTime.now().millisecondsSinceEpoch}_${item.productId}';
          await txn.insert('inventory_movements', {
            'id': movId,
            'product_id': item.productId,
            'product_name': prdName,
            'previous_stock': curStock,
            'change_quantity': item.quantity,
            'new_stock': newStock,
            'reason': 'Purchase (${purchase.purchaseInvoiceNumber})',
            'reference_id': pKey,
            'operator_name': purchase.createdBy,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      if (purchase.supplierId.isNotEmpty && purchase.remainingBalance > 0) {
        final supMaps = await txn.query('suppliers', where: 'id = ?', whereArgs: [purchase.supplierId]);
        if (supMaps.isNotEmpty) {
          final curBal = (supMaps.first['current_balance'] as num?)?.toDouble() ?? 0.0;
          final newBal = curBal + purchase.remainingBalance;
          await txn.update(
            'suppliers',
            {'current_balance': newBal},
            where: 'id = ?',
            whereArgs: [purchase.supplierId],
          );
        }
      }
    });

    _purchaseController.add(await getPurchases());
    _productController.add(await getProducts());
    _movementController.add(await getInventoryMovements());
    _supplierController.add(await getSuppliers());
  }

  // --- SALES & POS (SQLITE) ---
  Stream<List<Sale>> get salesStream async* {
    yield await getSales();
    yield* _saleController.stream;
  }

  Future<List<Sale>> getSales() async {
    final db = await _sqlite.database;
    final saleMaps = await db.query('sales', orderBy: 'date DESC');
    List<Sale> sales = [];

    for (var sMap in saleMaps) {
      final sId = sMap['id'].toString();
      final itemMaps = await db.query('sale_items', where: 'sale_id = ?', whereArgs: [sId]);
      List<SaleItem> items = itemMaps.map((iMap) {
        return SaleItem(
          productId: iMap['product_id']?.toString() ?? '',
          name: iMap['name']?.toString() ?? '',
          sku: iMap['sku']?.toString() ?? '',
          price: (iMap['price'] as num?)?.toDouble() ?? 0.0,
          purchasePrice: (iMap['purchase_price'] as num?)?.toDouble() ?? 0.0,
          quantity: (iMap['quantity'] as num?)?.toInt() ?? 1,
          discount: (iMap['discount'] as num?)?.toDouble() ?? 0.0,
          total: (iMap['total'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      sales.add(Sale(
        id: sId,
        invoiceNumber: sMap['invoice_number']?.toString() ?? '',
        date: sMap['date'] != null ? DateTime.tryParse(sMap['date'].toString()) ?? DateTime.now() : DateTime.now(),
        customerId: sMap['customer_id']?.toString() ?? '',
        customerName: sMap['customer_name']?.toString() ?? 'Walk-in Customer',
        customerPhone: sMap['customer_phone']?.toString() ?? '',
        items: items,
        subtotal: (sMap['subtotal'] as num?)?.toDouble() ?? 0.0,
        discount: (sMap['discount'] as num?)?.toDouble() ?? 0.0,
        tax: (sMap['tax'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (sMap['total_amount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (sMap['paid_amount'] as num?)?.toDouble() ?? 0.0,
        changeAmount: (sMap['change_amount'] as num?)?.toDouble() ?? 0.0,
        remainingBalance: (sMap['remaining_balance'] as num?)?.toDouble() ?? 0.0,
        paymentMethod: sMap['payment_method']?.toString() ?? 'Cash',
        status: sMap['status']?.toString() ?? 'Completed',
        notes: sMap['notes']?.toString() ?? '',
        createdBy: sMap['created_by']?.toString() ?? 'Admin',
      ));
    }
    return sales;
  }

  Future<String> completeSale({
    required Sale sale,
    required List<Product> currentProducts,
  }) async {
    for (var item in sale.items) {
      final product = currentProducts.firstWhere(
        (p) => p.id == item.productId,
        orElse: () => Product(id: '', name: item.name, sellingPrice: item.price, stock: 99999),
      );
      if (product.id.isNotEmpty && product.stock < item.quantity) {
        throw Exception('Insufficient stock for "${item.name}". Available: ${product.stock}, Required: ${item.quantity}');
      }
    }

    final saleKey = sale.id.isNotEmpty ? sale.id : 'sale_${DateTime.now().millisecondsSinceEpoch}';

    await _sqlite.transaction((txn) async {
      await txn.insert('sales', {
        'id': saleKey,
        'invoice_number': sale.invoiceNumber,
        'date': sale.date.toIso8601String(),
        'customer_id': sale.customerId.isEmpty ? null : sale.customerId,
        'customer_name': sale.customerName,
        'customer_phone': sale.customerPhone,
        'subtotal': sale.subtotal,
        'discount': sale.discount,
        'tax': sale.tax,
        'total_amount': sale.totalAmount,
        'paid_amount': sale.paidAmount,
        'change_amount': sale.changeAmount,
        'remaining_balance': sale.remainingBalance,
        'payment_method': sale.paymentMethod,
        'status': sale.status,
        'notes': sale.notes,
        'created_by': sale.createdBy,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (var item in sale.items) {
        await txn.insert('sale_items', {
          'sale_id': saleKey,
          'product_id': item.productId,
          'name': item.name,
          'sku': item.sku,
          'price': item.price,
          'purchase_price': item.purchasePrice,
          'quantity': item.quantity,
          'discount': item.discount,
          'total': item.total,
        });

        final prdMaps = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        if (prdMaps.isNotEmpty) {
          final curStock = (prdMaps.first['stock'] as num?)?.toInt() ?? 0;
          final newStock = curStock - item.quantity;
          final prdName = prdMaps.first['name']?.toString() ?? item.name;

          await txn.update(
            'products',
            {'stock': newStock, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          final movId = 'mov_${DateTime.now().millisecondsSinceEpoch}_${item.productId}';
          await txn.insert('inventory_movements', {
            'id': movId,
            'product_id': item.productId,
            'product_name': prdName,
            'previous_stock': curStock,
            'change_quantity': -item.quantity,
            'new_stock': newStock,
            'reason': 'Sale (${sale.invoiceNumber})',
            'reference_id': saleKey,
            'operator_name': sale.createdBy,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      if (sale.customerId.isNotEmpty && sale.remainingBalance > 0) {
        final custMaps = await txn.query('customers', where: 'id = ?', whereArgs: [sale.customerId]);
        if (custMaps.isNotEmpty) {
          final curBal = (custMaps.first['current_balance'] as num?)?.toDouble() ?? 0.0;
          final totPurchases = (custMaps.first['total_purchases'] as num?)?.toDouble() ?? 0.0;
          final newBal = curBal + sale.remainingBalance;
          final newTotalPurchases = totPurchases + sale.totalAmount;

          await txn.update(
            'customers',
            {
              'current_balance': newBal,
              'total_purchases': newTotalPurchases,
              'last_purchase_date': sale.date.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [sale.customerId],
          );
        }
      } else if (sale.customerId.isNotEmpty) {
        final custMaps = await txn.query('customers', where: 'id = ?', whereArgs: [sale.customerId]);
        if (custMaps.isNotEmpty) {
          final totPurchases = (custMaps.first['total_purchases'] as num?)?.toDouble() ?? 0.0;
          final newTotalPurchases = totPurchases + sale.totalAmount;

          await txn.update(
            'customers',
            {
              'total_purchases': newTotalPurchases,
              'last_purchase_date': sale.date.toIso8601String(),
            },
            where: 'id = ?',
            whereArgs: [sale.customerId],
          );
        }
      }
    });

    _saleController.add(await getSales());
    _productController.add(await getProducts());
    _movementController.add(await getInventoryMovements());
    _customerController.add(await getCustomers());

    return saleKey;
  }

  Future<void> processSaleReturn({
    required Sale sale,
    required List<Product> currentProducts,
    required String reason,
  }) async {
    await _sqlite.transaction((txn) async {
      await txn.update(
        'sales',
        {'status': 'Returned'},
        where: 'id = ?',
        whereArgs: [sale.id],
      );

      for (var item in sale.items) {
        final prdMaps = await txn.query('products', where: 'id = ?', whereArgs: [item.productId]);
        if (prdMaps.isNotEmpty) {
          final curStock = (prdMaps.first['stock'] as num?)?.toInt() ?? 0;
          final newStock = curStock + item.quantity;
          final prdName = prdMaps.first['name']?.toString() ?? item.name;

          await txn.update(
            'products',
            {'stock': newStock, 'updated_at': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [item.productId],
          );

          final movId = 'mov_${DateTime.now().millisecondsSinceEpoch}_${item.productId}';
          await txn.insert('inventory_movements', {
            'id': movId,
            'product_id': item.productId,
            'product_name': prdName,
            'previous_stock': curStock,
            'change_quantity': item.quantity,
            'new_stock': newStock,
            'reason': 'Sale Return ($reason)',
            'reference_id': sale.id,
            'operator_name': sale.createdBy,
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }
    });

    _saleController.add(await getSales());
    _productController.add(await getProducts());
    _movementController.add(await getInventoryMovements());
  }

  // --- EXPENSES (SQLITE) ---
  Stream<List<Expense>> get expensesStream async* {
    yield await getExpenses();
    yield* _expenseController.stream;
  }

  Future<List<Expense>> getExpenses() async {
    final db = await _sqlite.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    if (maps.isEmpty) {
      await _seedDefaultExpenseAndAudit(db);
      final seededMaps = await db.query('expenses', orderBy: 'date DESC');
      return seededMaps.map(_expenseFromSqlMap).toList();
    }
    return maps.map(_expenseFromSqlMap).toList();
  }

  Expense _expenseFromSqlMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      description: map['description']?.toString() ?? '',
      paymentMethod: map['payment_method']?.toString() ?? 'Cash',
      createdBy: map['created_by']?.toString() ?? 'Admin',
    );
  }

  Map<String, dynamic> _expenseToSqlMap(Expense expense) {
    return {
      'id': expense.id,
      'category': expense.category,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'description': expense.description,
      'payment_method': expense.paymentMethod,
      'created_by': expense.createdBy,
    };
  }

  Future<void> addExpense(Expense expense) async {
    final db = await _sqlite.database;
    await db.insert('expenses', _expenseToSqlMap(expense), conflictAlgorithm: ConflictAlgorithm.replace);
    await logAudit(
      action: 'Expense Created',
      details: 'Added expense "${expense.category}" of Rs ${expense.amount}',
      module: 'Expenses',
    );
    _expenseController.add(await getExpenses());
  }

  Future<void> deleteExpense(String expenseId, String category, double amount) async {
    final db = await _sqlite.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [expenseId]);
    await logAudit(
      action: 'Expense Deleted',
      details: 'Removed expense "$category" of Rs $amount (ID: $expenseId)',
      module: 'Expenses',
    );
    _expenseController.add(await getExpenses());
  }

  // --- INVENTORY MOVEMENTS (SQLITE) ---
  Stream<List<InventoryMovement>> get inventoryMovementsStream async* {
    yield await getInventoryMovements();
    yield* _movementController.stream;
  }

  Future<List<InventoryMovement>> getInventoryMovements() async {
    final db = await _sqlite.database;
    final maps = await db.query('inventory_movements', orderBy: 'timestamp DESC');
    return maps.map((map) {
      return InventoryMovement(
        id: map['id']?.toString() ?? '',
        productId: map['product_id']?.toString() ?? '',
        productName: map['product_name']?.toString() ?? '',
        previousStock: (map['previous_stock'] as num?)?.toInt() ?? 0,
        changeQuantity: (map['change_quantity'] as num?)?.toInt() ?? 0,
        newStock: (map['new_stock'] as num?)?.toInt() ?? 0,
        reason: map['reason']?.toString() ?? '',
        referenceId: map['reference_id']?.toString() ?? '',
        operatorName: map['operator_name']?.toString() ?? 'Admin',
        timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
      );
    }).toList();
  }

  // --- AUDIT LOGS (SQLITE) ---
  Stream<List<AuditLog>> get auditLogsStream async* {
    yield await getAuditLogs();
    yield* _auditController.stream;
  }

  Future<List<AuditLog>> getAuditLogs() async {
    final db = await _sqlite.database;
    final maps = await db.query('audit_logs', orderBy: 'timestamp DESC');
    if (maps.isEmpty) {
      await _seedDefaultExpenseAndAudit(db);
      final seededMaps = await db.query('audit_logs', orderBy: 'timestamp DESC');
      return seededMaps.map(_auditFromSqlMap).toList();
    }
    return maps.map(_auditFromSqlMap).toList();
  }

  AuditLog _auditFromSqlMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id']?.toString() ?? '',
      user: map['user']?.toString() ?? 'Admin',
      action: map['action']?.toString() ?? '',
      details: map['details']?.toString() ?? '',
      module: map['module']?.toString() ?? '',
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> _auditToSqlMap(AuditLog log) {
    return {
      'id': log.id,
      'user': log.user,
      'action': log.action,
      'details': log.details,
      'module': log.module,
      'timestamp': log.timestamp.toIso8601String(),
    };
  }

  Future<void> logAudit({required String action, required String details, required String module, String user = 'Admin'}) async {
    final log = AuditLog(id: 'log_${DateTime.now().millisecondsSinceEpoch}', user: user, action: action, details: details, module: module);
    final db = await _sqlite.database;
    await db.insert('audit_logs', _auditToSqlMap(log), conflictAlgorithm: ConflictAlgorithm.replace);
    _auditController.add(await getAuditLogs());
  }

  // --- SETTINGS (SQLITE) ---
  Stream<ShopSettings> get shopSettingsStream async* {
    yield await getShopSettings();
    yield* _settingsController.stream;
  }

  Future<ShopSettings> getShopSettings() async {
    final db = await _sqlite.database;
    final maps = await db.query('settings');
    if (maps.isEmpty) {
      await _seedDefaultSettings(db);
      return ShopSettings();
    }
    Map<String, dynamic> settingsMap = {};
    for (var m in maps) {
      settingsMap[m['key'].toString()] = m['value'];
    }
    return ShopSettings.fromMap(settingsMap);
  }

  Future<void> updateShopSettings(ShopSettings settings) async {
    final map = settings.toMap();

    await _sqlite.transaction((txn) async {
      for (var entry in map.entries) {
        await txn.insert(
          'settings',
          {'key': entry.key, 'value': entry.value.toString()},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });

    await logAudit(
      action: 'Settings Updated',
      details: 'Updated shop settings and configuration',
      module: 'Settings',
    );

    _settingsController.add(await getShopSettings());
  }

  // --- SEED DEFAULT DATA ---
  Future<void> _seedDefaultData(Database db) async {
    const catId = 'cat_default_general';
    await db.insert('categories', {
      'id': catId,
      'name': 'General',
      'description': 'Default product category',
      'icon_name': 'category',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    const prdId = 'prd_default_1';
    await db.insert('products', {
      'id': prdId,
      'name': 'Sample Milk Pack',
      'sku': 'MILK-001',
      'barcode': '123456789',
      'category_id': catId,
      'category_name': 'General',
      'brand': 'Nestle',
      'description': 'Fresh milk 1L pack',
      'purchase_price': 250.0,
      'selling_price': 300.0,
      'stock': 50,
      'min_stock': 5,
      'unit': 'Pcs',
      'supplier_id': null,
      'image_url': '',
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _seedDefaultCustomerAndSupplier(Database db) async {
    await db.insert('customers', {
      'id': 'cust_default_1',
      'name': 'Ali Khan',
      'phone': '0300-1234567',
      'email': 'ali@gmail.com',
      'address': 'Islamabad',
      'current_balance': 0.0,
      'total_purchases': 1500.0,
      'notes': 'Regular walk-in client',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('suppliers', {
      'id': 'sup_default_1',
      'name': 'Ahmad Traders',
      'company_name': 'Ahmad Wholesale Dist.',
      'phone': '051-5551234',
      'email': 'ahmad@traders.pk',
      'address': 'Rawalpindi',
      'current_balance': 0.0,
      'notes': 'Primary grocery supplier',
      'created_at': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _seedDefaultExpenseAndAudit(Database db) async {
    await db.insert('expenses', {
      'id': 'exp_default_1',
      'category': 'Utilities',
      'amount': 1200.0,
      'date': DateTime.now().toIso8601String(),
      'description': 'Monthly Electricity Bill',
      'payment_method': 'Cash',
      'created_by': 'Admin',
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('audit_logs', {
      'id': 'log_default_1',
      'user': 'Admin',
      'action': 'System Initialized',
      'details': 'SQLite local-first architecture initialized successfully',
      'module': 'System',
      'timestamp': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> _seedDefaultSettings(Database db) async {
    final settings = ShopSettings();
    final map = settings.toMap();
    for (var entry in map.entries) {
      await db.insert('settings', {
        'key': entry.key,
        'value': entry.value.toString(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }
}
