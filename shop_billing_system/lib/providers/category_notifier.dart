import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import 'shop_providers.dart';

final categoryNotifierProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return CategoryNotifier(repo);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final dynamic _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final cats = await _repository.getCategories();
      state = AsyncValue.data(cats);

      _repository.categoriesStream.listen((cats) {
        if (mounted) {
          state = AsyncValue.data(cats);
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

  Future<void> addCategory(Category category) async {
    final catWithId = Category(
      id: category.id.isEmpty ? 'cat_${DateTime.now().millisecondsSinceEpoch}' : category.id,
      name: category.name,
      description: category.description,
      iconName: category.iconName,
      isActive: category.isActive,
      createdAt: category.createdAt,
    );

    await _repository.addCategory(catWithId);
    loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _repository.updateCategory(category);
    loadCategories();
  }

  Future<void> deleteCategory(String categoryId, String categoryName) async {
    await _repository.deleteCategory(categoryId, categoryName);
    loadCategories();
  }
}
