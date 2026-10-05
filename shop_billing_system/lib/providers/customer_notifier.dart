import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import 'shop_providers.dart';

final customerNotifierProvider = StateNotifierProvider<CustomerNotifier, AsyncValue<List<Customer>>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return CustomerNotifier(repo);
});

class CustomerNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final dynamic _repository;

  CustomerNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final customers = await _repository.getCustomers();
      state = AsyncValue.data(customers);

      _repository.customersStream.listen((customers) {
        if (mounted) {
          state = AsyncValue.data(customers);
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

  Future<void> addCustomer(Customer customer) async {
    final custWithId = Customer(
      id: customer.id.isEmpty ? 'cust_${DateTime.now().millisecondsSinceEpoch}' : customer.id,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      currentBalance: customer.currentBalance,
      totalPurchases: customer.totalPurchases,
      lastPurchaseDate: customer.lastPurchaseDate,
      notes: customer.notes,
      createdAt: customer.createdAt,
    );

    await _repository.addCustomer(custWithId);
    loadCustomers();
  }

  Future<void> updateCustomer(Customer customer) async {
    await _repository.updateCustomer(customer);
    loadCustomers();
  }

  Future<void> recordPayment({
    required String customerId,
    required String customerName,
    required double amount,
    required String paymentMethod,
    required String notes,
  }) async {
    await _repository.recordCustomerPayment(
      customerId: customerId,
      customerName: customerName,
      amount: amount,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    loadCustomers();
  }
}
