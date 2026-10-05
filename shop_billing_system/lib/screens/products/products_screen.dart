import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../providers/product_notifier.dart';
import '../../providers/category_notifier.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStockStatus = 'All'; // All, In Stock, Low Stock, Out of Stock

  void _showProductDialog(List<Category> categories, [Product? existingProduct]) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: existingProduct?.name ?? '');
    final skuController = TextEditingController(text: existingProduct?.sku ?? '');
    final barcodeController = TextEditingController(text: existingProduct?.barcode ?? '');
    final purchasePriceController = TextEditingController(
        text: existingProduct != null ? existingProduct.purchasePrice.toString() : '0.0');
    final sellingPriceController = TextEditingController(
        text: existingProduct != null ? existingProduct.sellingPrice.toString() : '0.0');
    final stockController = TextEditingController(
        text: existingProduct != null ? existingProduct.stock.toString() : '10');
    final minStockController = TextEditingController(
        text: existingProduct != null ? existingProduct.minStock.toString() : '5');
    final descController = TextEditingController(text: existingProduct?.description ?? '');

    String categoryId = existingProduct?.categoryId ?? (categories.isNotEmpty ? categories.first.id : '');
    String categoryName = existingProduct?.categoryName ?? (categories.isNotEmpty ? categories.first.name : 'General');
    String unit = existingProduct?.unit ?? 'Pcs';
    bool isActive = existingProduct?.isActive ?? true;

    final unitsList = ['Pcs', 'Kg', 'Ltr', 'Box', 'Pack', 'Meter', 'Dozen', 'Set'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(existingProduct == null ? 'Add New Product' : 'Edit Product'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 550,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Product Name *',
                            prefixIcon: Icon(Icons.shopping_bag),
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty) ? 'Product name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: skuController,
                                decoration: const InputDecoration(
                                  labelText: 'SKU (e.g. PRD-001)',
                                  prefixIcon: Icon(Icons.qr_code),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: barcodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Barcode',
                                  prefixIcon: Icon(Icons.barcode_reader),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: categories.any((c) => c.id == categoryId) ? categoryId : null,
                                hint: const Text('Category'),
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category),
                                ),
                                items: categories.map((c) {
                                  return DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      categoryId = val;
                                      categoryName = categories.firstWhere((c) => c.id == val).name;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: unit,
                                decoration: const InputDecoration(
                                  labelText: 'Unit',
                                  prefixIcon: Icon(Icons.square_foot),
                                ),
                                items: unitsList.map((u) {
                                  return DropdownMenuItem(value: u, child: Text(u));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setDialogState(() => unit = val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchasePriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Cost Price (Rs) *',
                                  prefixIcon: Icon(Icons.price_change_outlined),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) return 'Invalid price';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: sellingPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Selling Price (Rs) *',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                validator: (val) {
                                  if (val == null || double.tryParse(val) == null) return 'Invalid price';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Stock Qty *',
                                  prefixIcon: Icon(Icons.inventory),
                                ),
                                validator: (val) {
                                  if (val == null || int.tryParse(val) == null) return 'Invalid quantity';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: minStockController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Min Stock Level',
                                  prefixIcon: Icon(Icons.warning_amber),
                                ),
                                validator: (val) {
                                  if (val == null || int.tryParse(val) == null) return 'Invalid quantity';
                                  return null;
                                },
                              ),
                            ),
                          ],
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
                        const SizedBox(height: 12),
                        SwitchListTile(
                          title: const Text('Product Active'),
                          subtitle: const Text('Inactive products will be hidden from POS sales'),
                          value: isActive,
                          onChanged: (val) => setDialogState(() => isActive = val),
                        ),
                      ],
                    ),
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
                      final product = Product(
                        id: existingProduct?.id ?? '',
                        name: nameController.text.trim(),
                        sku: skuController.text.trim(),
                        barcode: barcodeController.text.trim(),
                        categoryId: categoryId,
                        categoryName: categoryName,
                        purchasePrice: double.parse(purchasePriceController.text.trim()),
                        sellingPrice: double.parse(sellingPriceController.text.trim()),
                        stock: int.parse(stockController.text.trim()),
                        minStock: int.parse(minStockController.text.trim()),
                        unit: unit,
                        description: descController.text.trim(),
                        isActive: isActive,
                        createdAt: existingProduct?.createdAt,
                      );

                      if (existingProduct == null) {
                        await ref.read(productNotifierProvider.notifier).addProduct(product);
                      } else {
                        await ref.read(productNotifierProvider.notifier).updateProduct(product);
                      }

                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Text(existingProduct == null ? 'Save Product' : 'Update Product'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showQuickStockDialog(Product product) {
    final qtyController = TextEditingController(text: product.stock.toString());
    final reasonController = TextEditingController(text: 'Manual stock adjustment');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Adjust Stock for ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current Stock: ${product.stock} ${product.unit}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'New Stock Quantity',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Adjustment Reason',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newQty = int.tryParse(qtyController.text.trim());
                if (newQty != null) {
                  await ref.read(productNotifierProvider.notifier).adjustStock(
                        product,
                        newQty,
                        reasonController.text.trim(),
                      );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Stock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return productsAsync.when(
      loading: () => const AppLoadingState(message: 'Loading Products...'),
      error: (err, st) => AppErrorState(
        message: err.toString(),
        onRetry: () => ref.refresh(productNotifierProvider),
      ),
      data: (products) {
        return categoriesAsync.when(
          loading: () => const AppLoadingState(message: 'Loading Categories...'),
          error: (err, st) => AppErrorState(
            message: err.toString(),
            onRetry: () => ref.refresh(categoryNotifierProvider),
          ),
          data: (categories) {
            final filteredProducts = products.where((p) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch = p.name.toLowerCase().contains(query) ||
                  p.sku.toLowerCase().contains(query) ||
                  p.barcode.toLowerCase().contains(query) ||
                  p.categoryName.toLowerCase().contains(query);

              final matchesCategory = _selectedCategory == 'All' || p.categoryId == _selectedCategory;

              bool matchesStock = true;
              if (_selectedStockStatus == 'In Stock') {
                matchesStock = !p.isOutOfStock && !p.isLowStock;
              } else if (_selectedStockStatus == 'Low Stock') {
                matchesStock = p.isLowStock;
              } else if (_selectedStockStatus == 'Out of Stock') {
                matchesStock = p.isOutOfStock;
              }

              return matchesSearch && matchesCategory && matchesStock;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Product Management',
                    subtitle: 'Manage shop products, prices, SKUs, barcodes, and minimum stock alerts',
                    actions: [
                      ElevatedButton.icon(
                        onPressed: () => _showProductDialog(categories),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add New Product'),
                      ),
                    ],
                  ),

                  SearchAndFilterBar(
                    hintText: 'Search by Product Name, SKU, Barcode...',
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    filterWidget: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            items: [
                              const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                              ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                            ],
                            onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedStockStatus,
                            decoration: const InputDecoration(
                              labelText: 'Stock Filter',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'All', child: Text('All Stock')),
                              DropdownMenuItem(value: 'In Stock', child: Text('In Stock')),
                              DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock')),
                              DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock')),
                            ],
                            onChanged: (val) => setState(() => _selectedStockStatus = val ?? 'All'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (filteredProducts.isEmpty)
                    EmptyStateWidget(
                      icon: Icons.inventory_2_outlined,
                      title: 'No Products Found',
                      description: 'Try clearing search filters or add a new product to your inventory.',
                      actionLabel: 'Add Product',
                      onAction: () => _showProductDialog(categories),
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomDataTable(
                          columns: const [
                            DataTableColumn(label: 'Product Name'),
                            DataTableColumn(label: 'SKU / Barcode'),
                            DataTableColumn(label: 'Category'),
                            DataTableColumn(label: 'Cost Price', numeric: true),
                            DataTableColumn(label: 'Selling Price', numeric: true),
                            DataTableColumn(label: 'Stock'),
                            DataTableColumn(label: 'Status'),
                            DataTableColumn(label: 'Actions'),
                          ],
                          rows: filteredProducts.map((p) {
                            return [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: const Icon(Icons.shopping_bag, size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(p.unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                p.sku.isNotEmpty ? p.sku : (p.barcode.isNotEmpty ? p.barcode : 'N/A'),
                                style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                              ),
                              Text(p.categoryName),
                              Text('Rs ${p.purchasePrice.toStringAsFixed(2)}'),
                              Text('Rs ${p.sellingPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${p.stock} ${p.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.swap_vert, size: 16, color: AppColors.accent),
                                    tooltip: 'Adjust Stock',
                                    onPressed: () => _showQuickStockDialog(p),
                                  ),
                                ],
                              ),
                              p.isOutOfStock
                                  ? StatusBadge.danger('Out of Stock')
                                  : (p.isLowStock
                                      ? StatusBadge.warning('Low Stock (${p.stock})')
                                      : StatusBadge.success('In Stock')),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 18, color: AppColors.info),
                                    tooltip: 'Edit Product',
                                    onPressed: () => _showProductDialog(categories, p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 18, color: AppColors.danger),
                                    tooltip: 'Archive / Delete Product',
                                    onPressed: () async {
                                      final confirmed = await ConfirmationDialog.show(
                                        context,
                                        title: 'Archive Product',
                                        message: 'Are you sure you want to archive product "${p.name}"?',
                                        confirmLabel: 'Archive',
                                      );
                                      if (confirmed) {
                                        await ref.read(productNotifierProvider.notifier).archiveOrDeleteProduct(p.id, p.name);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ];
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
