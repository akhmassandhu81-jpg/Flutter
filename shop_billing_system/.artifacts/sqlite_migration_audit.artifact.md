# SQLite Migration Audit & Architecture Analysis Report

**Target Platform:** Windows Desktop
**Current Backend:** Firebase Realtime Database + Hive Local Cache
**Future Target Backend:** Local SQLite Database (Fully Offline-First Windows App)

---

## 1. Project Architecture

### Folder Structure (`lib/`)
* `lib/main.dart`: App entry point, Firebase init, Hive init, ProviderScope setup.
* `lib/firebase_options.dart`: FlutterFire platform options.
* `lib/core/`
  * `constants/`: App color palettes and design tokens.
  * `services/`: `AuthService`, `ConnectivityService`, `LocalStorageService` (Hive), `SyncEngine`.
  * `theme/`: Light and Dark Material 3 theme configurations.
  * `widgets/`: Reusable components (`StatCard`, `CustomDataTable`, `StatusBadge`, `PageHeader`, `SearchAndFilterBar`, `AppStates`, etc.).
* `lib/models/`: Domain entities (`Product`, `Category`, `Sale`, `Purchase`, `Customer`, `Supplier`, `Expense`, `InventoryMovement`, `AuditLog`, `ShopSettings`, `SyncOperation`, `UserSession`).
* `lib/providers/`: Riverpod state management (`auth_provider.dart`, `connectivity_provider.dart`, `sync_provider.dart`, `shop_providers.dart`, `product_notifier.dart`, `category_notifier.dart`, `customer_notifier.dart`, `supplier_notifier.dart`).
* `lib/repositories/`: `ShopRepository` (unifying data source calls).
* `lib/screens/`: Feature screens (`DashboardScreen`, `PosScreen`, `ProductsScreen`, `CategoriesScreen`, `InventoryScreen`, `PurchasesScreen`, `SuppliersScreen`, `CustomersScreen`, `SalesScreen`, `ExpensesScreen`, `ReportsScreen`, `AuditScreen`, `SettingsScreen`, `ReceiptDialog`).

---

## 2. Firebase Usage

Firebase is currently initialized in `lib/main.dart` and accessed exclusively through `ShopRepository` (`lib/repositories/shop_repository.dart`).

| File Path | Class / Function | Data Read | Data Written / Updated | Data Deleted |
| --- | --- | --- | --- | --- |
| `lib/main.dart` | `main()` | None (Init only) | None | None |
| `lib/repositories/shop_repository.dart` | `productsStream` | `/products` | None | None |
| `lib/repositories/shop_repository.dart` | `addProduct` | None | `/products/{id}` | None |
| `lib/repositories/shop_repository.dart` | `updateProduct` | None | `/products/{id}` | None |
| `lib/repositories/shop_repository.dart` | `deleteProduct` | None | None | `/products/{id}` |
| `lib/repositories/shop_repository.dart` | `adjustStock` | None | `/products/{id}`, `/inventoryMovements` | None |
| `lib/repositories/shop_repository.dart` | `categoriesStream` | `/categories` | None | None |
| `lib/repositories/shop_repository.dart` | `addCategory` / `updateCategory` | None | `/categories/{id}` | None |
| `lib/repositories/shop_repository.dart` | `deleteCategory` | None | None | `/categories/{id}` |
| `lib/repositories/shop_repository.dart` | `salesStream` | `/sales` | None | None |
| `lib/repositories/shop_repository.dart` | `completeSale` | `/customers/{id}` | `/sales/{id}`, `/products/{id}`, `/customers/{id}`, `/inventoryMovements` | None |
| `lib/repositories/shop_repository.dart` | `processSaleReturn` | None | `/sales/{id}`, `/products/{id}`, `/inventoryMovements` | None |
| `lib/repositories/shop_repository.dart` | `purchasesStream` | `/purchases` | None | None |
| `lib/repositories/shop_repository.dart` | `addPurchase` | `/suppliers/{id}` | `/purchases/{id}`, `/products/{id}`, `/suppliers/{id}`, `/inventoryMovements` | None |
| `lib/repositories/shop_repository.dart` | `customersStream` | `/customers` | None | None |
| `lib/repositories/shop_repository.dart` | `addCustomer` / `updateCustomer` | None | `/customers/{id}` | None |
| `lib/repositories/shop_repository.dart` | `recordCustomerPayment` | `/customers/{id}` | `/customers/{id}` | None |
| `lib/repositories/shop_repository.dart` | `suppliersStream` | `/suppliers` | None | None |
| `lib/repositories/shop_repository.dart` | `addSupplier` / `updateSupplier` | None | `/suppliers/{id}` | None |
| `lib/repositories/shop_repository.dart` | `recordSupplierPayment` | `/suppliers/{id}` | `/suppliers/{id}` | None |
| `lib/repositories/shop_repository.dart` | `expensesStream` | `/expenses` | None | None |
| `lib/repositories/shop_repository.dart` | `addExpense` | None | `/expenses/{id}` | None |
| `lib/repositories/shop_repository.dart` | `deleteExpense` | None | None | `/expenses/{id}` |
| `lib/repositories/shop_repository.dart` | `inventoryMovementsStream` | `/inventoryMovements` | None | None |
| `lib/repositories/shop_repository.dart` | `auditLogsStream` | `/auditLogs` | None | None |
| `lib/repositories/shop_repository.dart` | `shopSettingsStream` | `/settings` | `/settings` | None |

---

## 3. Database / Data Models

1. **Product**: ID, SKU, Barcode, Category ID/Name, Brand, Description, Purchase Price, Selling Price, Stock, Min Stock, Unit, Supplier ID, Image URL, IsActive, CreatedAt, UpdatedAt.
2. **Category**: ID, Name, Description, IconName, IsActive, CreatedAt.
3. **Sale & SaleItem**: Sale ID, Invoice Number, Date, Customer ID/Name/Phone, Items List, Subtotal, Discount, Tax, Total Amount, Paid Amount, Change Amount, Remaining Balance, Payment Method, Status, Notes, CreatedBy.
4. **Purchase & PurchaseItem**: Purchase ID, Purchase Invoice Number, Date, Supplier ID/Name, Items List, Total Amount, Paid Amount, Remaining Balance, Payment Status, Notes, CreatedBy.
5. **Customer**: ID, Name, Phone, Email, Address, Current Balance, Total Purchases, Last Purchase Date, Notes, CreatedAt.
6. **Supplier**: ID, Name, Company Name, Phone, Email, Address, Current Balance, Notes, CreatedAt.
7. **Expense**: ID, Category, Amount, Date, Description, Payment Method, CreatedBy.
8. **InventoryMovement**: ID, Product ID, Product Name, Previous Stock, Change Quantity, New Stock, Reason, Reference ID, Operator Name, Timestamp.
9. **AuditLog**: ID, User, Action, Details, Module, Timestamp.
10. **ShopSettings**: Shop Name, Address, Phone, Email, Tax Number, Currency Symbol, Default Tax Rate, Default Min Stock Level, Receipt Footer Note.

---

## 4. Firebase Database Structure

```text
root
├── products
│   └── {productId} -> {name, sku, barcode, categoryId, categoryName, purchasePrice, sellingPrice, stock, minStock, unit, isActive, createdAt, updatedAt}
├── categories
│   └── {categoryId} -> {name, description, iconName, isActive, createdAt}
├── sales
│   └── {saleId} -> {invoiceNumber, date, customerId, customerName, items: [{productId, name, price, quantity, total}], subtotal, discount, tax, totalAmount, paidAmount, changeAmount, remainingBalance, paymentMethod, status, notes}
├── purchases
│   └── {purchaseId} -> {purchaseInvoiceNumber, date, supplierId, supplierName, items: [{productId, name, unitPrice, quantity, total}], totalAmount, paidAmount, remainingBalance, paymentStatus, notes}
├── customers
│   └── {customerId} -> {name, phone, email, address, currentBalance, totalPurchases, lastPurchaseDate, notes, createdAt}
├── suppliers
│   └── {supplierId} -> {name, companyName, phone, email, address, currentBalance, notes, createdAt}
├── expenses
│   └── {expenseId} -> {category, amount, date, description, paymentMethod, createdBy}
├── inventoryMovements
│   └── {movementId} -> {productId, productName, previousStock, changeQuantity, newStock, reason, referenceId, operatorName, timestamp}
├── auditLogs
│   └── {logId} -> {user, action, details, module, timestamp}
└── settings
    └── {shopName, address, phone, email, taxNumber, currencySymbol, defaultTaxRate, defaultMinStockLevel, receiptFooterNote}
```

---

## 5. Riverpod / State Management

* Providers defined in `shop_providers.dart`, `connectivity_provider.dart`, `auth_provider.dart`, `sync_provider.dart`.
* Notifiers defined in `product_notifier.dart`, `category_notifier.dart`, `customer_notifier.dart`, `supplier_notifier.dart`.
* **Migration Impact**: After SQLite migration, these providers will continue to watch repositories (`ShopRepository`), but `ShopRepository` will read/write against SQLite instead of Firebase/Hive. The Riverpod UI layer requires zero modifications because `ShopRepository` encapsulates the underlying data source.

---

## 6. Repository Architecture

* The project **already has a clean repository layer** (`ShopRepository`).
* UI → Riverpod Providers/Notifiers → `ShopRepository` → Data Sources.
* This abstraction layer makes SQLite migration exceptionally clean.

---

## 7. Offline Capability

* The application currently features an **offline-first hybrid architecture**:
  1. Local storage via **Hive** (`LocalStorageService`) serving data locally.
  2. `SyncEngine` and `SyncOperation` queueing mutations (`pending`, `syncing`, `synced`, `failed`).
  3. `ConnectivityService` (`connectivity_plus`) detecting online/offline transitions.

---

## 8. Windows Compatibility

* Fully compatible with Windows.
* `hive_flutter` and `sqflite_common_ffi` (or `sqlite3`) support Windows file-system access (`path_provider`).

---

## 9. Migration Impact Table

| Feature | Current Firebase Implementation | Files Affected | SQLite Migration Difficulty |
| --- | --- | --- | --- |
| Products | `ShopRepository`, `ProductNotifier`, Hive | `shop_repository.dart`, `product_notifier.dart` | Low |
| Categories | `ShopRepository`, `CategoryNotifier`, Hive | `shop_repository.dart`, `category_notifier.dart` | Low |
| Sales & POS | `ShopRepository`, Hive RTDB listeners | `shop_repository.dart`, `pos_screen.dart` | Medium |
| Purchases | `ShopRepository`, Hive | `shop_repository.dart`, `purchases_screen.dart` | Medium |
| Customers | `ShopRepository`, `CustomerNotifier`, Hive | `shop_repository.dart`, `customer_notifier.dart` | Low |
| Suppliers | `ShopRepository`, `SupplierNotifier`, Hive | `shop_repository.dart`, `suppliers_screen.dart` | Low |
| Expenses | `ShopRepository`, Hive | `shop_repository.dart`, `expenses_screen.dart` | Low |
| Inventory & Movements | `ShopRepository`, Hive | `shop_repository.dart`, `inventory_screen.dart` | Low |
| Settings | `ShopRepository`, Hive | `shop_repository.dart`, `settings_screen.dart` | Low |

---

## 10. SQLite Database Design Proposal

* **Tables**: `products`, `categories`, `customers`, `suppliers`, `sales`, `sale_items`, `purchases`, `purchase_items`, `expenses`, `inventory_movements`, `audit_logs`, `settings`.
* **Primary Keys**: Integer auto-increment IDs or UUID string IDs.
* **Foreign Keys**: `sale_items.sale_id` → `sales.id`, `purchase_items.purchase_id` → `purchases.id`, `products.category_id` → `categories.id`, etc.
* **Indexes**: `idx_products_sku`, `idx_sales_date`, `idx_customers_name`.

---

## 11. Data Migration Strategy

* Export local Hive box data or Firebase JSON snapshots to structured SQLite INSERT statements upon first application launch.

---

## 12. Backup and Restore

* Implement file copy of the local SQLite `.db` file in the user's AppData directory (`path_provider`) for manual export and import restore.

---

## 13. Firebase Authentication

* Firebase Auth can be replaced with a local user session or local PIN/password authentication table in SQLite for standalone Windows desktop operation.

---

## 14. Final Migration Phased Plan

* Phase 1: SQLite dependency setup (`sqflite_common_ffi`).
* Phase 2: SQLite database helper & schema creation.
* Phase 3: Repository rewrite to query SQLite instead of Firebase.
* Phase 4–12: Testing, local backup/restore, and standalone Windows release build.

---

## Migration Risk Assessment
* **Low Risk**: Products, Categories, Customers, Suppliers, Expenses, Settings CRUD.
* **Medium Risk**: Inventory stock calculations and relational joins (`sale_items` + `sales`).
* **High Risk**: Transaction atomicity during POS checkout (Sale + Stock decrement + Customer balance update).
* **Critical Testing Requirement**: Verify 100% offline persistence and ACID transaction integrity on Windows before final release.
