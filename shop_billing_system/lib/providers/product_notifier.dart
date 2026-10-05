import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import 'shop_providers.dart';

final productNotifierProvider = StateNotifierProvider<ProductNotifier, AsyncValue<List<Product>>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return ProductNotifier(repo);
});

class ProductNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final dynamic _repository;

  ProductNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    try {
      final products = await _repository.getProducts();
      state = AsyncValue.data(products);

      _repository.productsStream.listen((products) {
        if (mounted) {
          state = AsyncValue.data(products);
        }
      }, onError: (err, stack) {
        if (mounted) {
          state = AsyncValue.error(err, stack);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final productWithId = product.copyWith(
        id: product.id.isEmpty ? 'prd_${DateTime.now().millisecondsSinceEpoch}' : product.id,
      );
      await _repository.addProduct(productWithId);
      loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _repository.updateProduct(product);
      loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> archiveOrDeleteProduct(String productId, String productName) async {
    try {
      await _repository.deleteProduct(productId, productName);
      loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> adjustStock(Product product, int newStock, String reason) async {
    try {
      await _repository.adjustStock(
        product: product,
        newQuantity: newStock,
        reason: reason,
      );
      loadProducts();
    } catch (e) {
      rethrow;
    }
  }
}
