import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../providers/category_notifier.dart';
import '../../models/category_model.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _searchQuery = '';

  void _showCategoryDialog([Category? existingCategory]) {
    final nameController = TextEditingController(text: existingCategory?.name ?? '');
    final descController = TextEditingController(text: existingCategory?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existingCategory == null ? 'Add New Category' : 'Edit Category'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Category Name *',
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  if (existingCategory == null) {
                    final newCategory = Category(
                      id: '',
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                    );
                    await ref.read(categoryNotifierProvider.notifier).addCategory(newCategory);
                  } else {
                    final updatedCategory = Category(
                      id: existingCategory.id,
                      name: nameController.text.trim(),
                      description: descController.text.trim(),
                      createdAt: existingCategory.createdAt,
                    );
                    await ref.read(categoryNotifierProvider.notifier).updateCategory(updatedCategory);
                  }
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(existingCategory == null ? 'Save Category' : 'Update Category'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return categoriesAsync.when(
      loading: () => const AppLoadingState(message: 'Loading Categories...'),
      error: (err, st) => AppErrorState(
        message: err.toString(),
        onRetry: () => ref.refresh(categoryNotifierProvider),
      ),
      data: (allCategories) {
        final filteredCategories = allCategories.where((c) {
          return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              c.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Category Management',
                subtitle: 'Organize your shop products into structured categories',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Category'),
                  ),
                ],
              ),

              SearchAndFilterBar(
                hintText: 'Search categories...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
              ),

              const SizedBox(height: 20),

              if (filteredCategories.isEmpty)
                EmptyStateWidget(
                  icon: Icons.category_outlined,
                  title: 'No Categories Found',
                  description: _searchQuery.isEmpty
                      ? 'Create your first product category to group items logically.'
                      : 'No category matches "$_searchQuery".',
                  actionLabel: _searchQuery.isEmpty ? 'Add Category' : null,
                  onAction: _searchQuery.isEmpty ? () => _showCategoryDialog() : null,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final cat = filteredCategories[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.category, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    cat.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (val) async {
                                    if (val == 'edit') {
                                      _showCategoryDialog(cat);
                                    } else if (val == 'delete') {
                                      final confirmed = await ConfirmationDialog.show(
                                        context,
                                        title: 'Delete Category',
                                        message: 'Are you sure you want to delete category "${cat.name}"?',
                                      );
                                      if (confirmed) {
                                        await ref.read(categoryNotifierProvider.notifier).deleteCategory(cat.id, cat.name);
                                      }
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red, size: 18),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              cat.description.isNotEmpty ? cat.description : 'No description provided.',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
