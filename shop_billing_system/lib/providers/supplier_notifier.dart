import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/supplier_model.dart';
import 'shop_providers.dart';

final supplierNotifierProvider = StateNotifierProvider<SupplierNotifier, AsyncValue<List<Supplier>>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return SupplierNotifier(repo);
});

class SupplierNotifier extends StateNotifier<AsyncValue<List<Supplier>>> {
  final dynamic _repository;

  SupplierNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {
    state = const AsyncValue.loading();
    try {
      final suppliers = await _repository.getSuppliers();
      state = AsyncValue.data(suppliers);

      _repository.suppliersStream.listen((suppliers) {
        if (mounted) {
          state = AsyncValue.data(suppliers);
        }
      }, onError: (err, st) {
        if (mounted) {
          state = AsyncValue.error(err, st);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    final supWithId = Supplier(
      id: supplier.id.isEmpty ? 'sup_${DateTime.now().millisecondsSinceEpoch}' : supplier.id,
      name: supplier.name,
      companyName: supplier.companyName,
      phone: supplier.phone,
      email: supplier.email,
      address: supplier.address,
      currentBalance: supplier.currentBalance,
      notes: supplier.notes,
      createdAt: supplier.createdAt,
    );

    await _repository.addSupplier(supWithId);
    loadSuppliers();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _repository.updateSupplier(supplier);
    loadSuppliers();
  }

  Future<void> recordPayment({
    required String supplierId,
    required String supplierName,
    required double amount,
    required String paymentMethod,
    required String notes,
  }) async {
    await _repository.recordSupplierPayment(
      supplierId: supplierId,
      supplierName: supplierName,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    loadSuppliers();
  }
}
