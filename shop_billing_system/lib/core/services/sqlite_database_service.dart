import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SqliteDatabaseService {
  static final SqliteDatabaseService _instance = SqliteDatabaseService._internal();
  factory SqliteDatabaseService() => _instance;
  SqliteDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for Windows desktop / cross-platform SQLite support
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    // Get proper per-user application data directory: %LOCALAPPDATA%\ShopBilling\
    Directory appDocDir = await getApplicationSupportDirectory();
    String dbPath = join(appDocDir.path, 'ShopBilling', 'shop_billing.db');

    // Ensure directory exists
    final dbDir = Directory(dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    // Open database with version 1 and relational schema creation
    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints enforcement
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon_name TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    // 2. Products Table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        category_id TEXT,
        category_name TEXT,
        brand TEXT,
        description TEXT,
        purchase_price REAL NOT NULL DEFAULT 0.0,
        selling_price REAL NOT NULL DEFAULT 0.0,
        stock INTEGER NOT NULL DEFAULT 0,
        min_stock INTEGER NOT NULL DEFAULT 5,
        unit TEXT NOT NULL DEFAULT 'Pcs',
        supplier_id TEXT,
        image_url TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      );
    ''');

    // 3. Customers Table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        current_balance REAL NOT NULL DEFAULT 0.0,
        total_purchases REAL NOT NULL DEFAULT 0.0,
        last_purchase_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 4. Suppliers Table
    await db.execute('''
      CREATE TABLE suppliers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        company_name TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        current_balance REAL NOT NULL DEFAULT 0.0,
        notes TEXT,
        created_at TEXT NOT NULL
      );
    ''');

    // 5. Sales Table
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        invoice_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        customer_id TEXT,
        customer_name TEXT,
        customer_phone TEXT,
        subtotal REAL NOT NULL DEFAULT 0.0,
        discount REAL NOT NULL DEFAULT 0.0,
        tax REAL NOT NULL DEFAULT 0.0,
        total_amount REAL NOT NULL DEFAULT 0.0,
        paid_amount REAL NOT NULL DEFAULT 0.0,
        change_amount REAL NOT NULL DEFAULT 0.0,
        remaining_balance REAL NOT NULL DEFAULT 0.0,
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        status TEXT NOT NULL DEFAULT 'Completed',
        notes TEXT,
        created_by TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE SET NULL
      );
    ''');

    // 6. Sale Items Table
    await db.execute('''
      CREATE TABLE sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        sku TEXT,
        price REAL NOT NULL DEFAULT 0.0,
        purchase_price REAL NOT NULL DEFAULT 0.0,
        quantity INTEGER NOT NULL DEFAULT 1,
        discount REAL NOT NULL DEFAULT 0.0,
        total REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
      );
    ''');

    // 7. Purchases Table
    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        purchase_invoice_number TEXT NOT NULL UNIQUE,
        date TEXT NOT NULL,
        supplier_id TEXT,
        supplier_name TEXT,
        total_amount REAL NOT NULL DEFAULT 0.0,
        paid_amount REAL NOT NULL DEFAULT 0.0,
        remaining_balance REAL NOT NULL DEFAULT 0.0,
        payment_status TEXT NOT NULL DEFAULT 'Paid',
        notes TEXT,
        created_by TEXT,
        FOREIGN KEY (supplier_id) REFERENCES suppliers (id) ON DELETE SET NULL
      );
    ''');

    // 8. Purchase Items Table
    await db.execute('''
      CREATE TABLE purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        purchase_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        name TEXT NOT NULL,
        unit_price REAL NOT NULL DEFAULT 0.0,
        quantity INTEGER NOT NULL DEFAULT 1,
        total REAL NOT NULL DEFAULT 0.0,
        FOREIGN KEY (purchase_id) REFERENCES purchases (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE RESTRICT
      );
    ''');

    // 9. Expenses Table
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0.0,
        date TEXT NOT NULL,
        description TEXT,
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        created_by TEXT
      );
    ''');

    // 10. Inventory Movements Table
    await db.execute('''
      CREATE TABLE inventory_movements (
        id TEXT PRIMARY KEY,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        previous_stock INTEGER NOT NULL,
        change_quantity INTEGER NOT NULL,
        new_stock INTEGER NOT NULL,
        reason TEXT NOT NULL,
        reference_id TEXT,
        operator_name TEXT,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      );
    ''');

    // 11. Audit Logs Table
    await db.execute('''
      CREATE TABLE audit_logs (
        id TEXT PRIMARY KEY,
        user TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        module TEXT NOT NULL,
        timestamp TEXT NOT NULL
      );
    ''');

    // 12. Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');

    // Strategic Indexes for Performance
    await db.execute('CREATE INDEX idx_products_sku ON products(sku);');
    await db.execute('CREATE INDEX idx_products_category ON products(category_id);');
    await db.execute('CREATE INDEX idx_sales_date ON sales(date);');
    await db.execute('CREATE INDEX idx_sales_customer ON sales(customer_id);');
    await db.execute('CREATE INDEX idx_purchases_supplier ON purchases(supplier_id);');
    await db.execute('CREATE INDEX idx_movements_product ON inventory_movements(product_id);');
  }

  // Helper method for atomic transactions
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }
}
