import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/shop_repository.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/sale_model.dart';
import '../models/purchase_model.dart';
import '../models/customer_model.dart';
import '../models/supplier_model.dart';
import '../models/expense_model.dart';
import '../models/shop_settings_model.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ShopRepository();
});

final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.productsStream;
});

final categoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.categoriesStream;
});

final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.salesStream;
});

final purchasesStreamProvider = StreamProvider<List<Purchase>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.purchasesStream;
});

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.customersStream;
});

final suppliersStreamProvider = StreamProvider<List<Supplier>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.suppliersStream;
});

final expensesStreamProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.expensesStream;
});

final shopSettingsStreamProvider = StreamProvider<ShopSettings>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return repo.shopSettingsStream;
});
