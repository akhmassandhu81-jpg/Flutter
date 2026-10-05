import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../providers/product_notifier.dart';
import '../../providers/shop_providers.dart';
import '../../models/product_model.dart';
import '../../models/inventory_movement_model.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _stockFilter = 'All'; // All, Low Stock, Out of Stock

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAdjustStockModal(Product product) {
    final newStockController = TextEditingController(text: product.stock.toString());
    final reasonController = TextEditingController(text: 'Manual Correction');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Adjust Inventory: ${product.name}'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.infoBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current In-Stock:'),
                        Text('${product.stock} ${product.unit}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'New Stock Quantity *',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    validator: (val) {
                      if (val == null || int.tryParse(val) == null) return 'Enter a valid stock number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: 'Manual Correction',
                    decoration: const InputDecoration(
                      labelText: 'Adjustment Reason',
                      prefixIcon: Icon(Icons.note),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Manual Correction', child: Text('Manual Correction')),
                      DropdownMenuItem(value: 'Restock / Purchase', child: Text('Restock / Purchase')),
                      DropdownMenuItem(value: 'Damage / Spoiled', child: Text('Damage / Spoiled')),
                      DropdownMenuItem(value: 'Expired', child: Text('Expired')),
                      DropdownMenuItem(value: 'Return', child: Text('Return')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (val) {
                      if (val != null) reasonController.text = val;
                    },
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
                  final newQty = int.parse(newStockController.text.trim());
                  await ref.read(productNotifierProvider.notifier).adjustStock(
                        product,
                        newQty,
                        reasonController.text.trim(),
                      );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Update Inventory'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productNotifierProvider);
    final movementsStream = ref.watch(shopRepositoryProvider).inventoryMovementsStream;

    return productsAsync.when(
      loading: () => const AppLoadingState(message: 'Loading Inventory Data...'),
      error: (err, st) => AppErrorState(message: err.toString(), onRetry: () => ref.refresh(productNotifierProvider)),
      data: (products) {
        return StreamBuilder<List<InventoryMovement>>(
          stream: movementsStream,
          builder: (context, moveSnap) {
            final movements = moveSnap.data ?? [];

            final int totalStockCount = products.fold(0, (sum, p) => sum + p.stock);
            final double totalCostValuation = products.fold(0.0, (sum, p) => sum + (p.stock * p.purchasePrice));
            final double totalRetailValuation = products.fold(0.0, (sum, p) => sum + (p.stock * p.sellingPrice));
            final double potentialProfit = totalRetailValuation - totalCostValuation;

            final lowStockProducts = products.where((p) => p.isLowStock).toList();
            final outOfStockProducts = products.where((p) => p.isOutOfStock).toList();

            final filteredProducts = products.where((p) {
              final query = _searchQuery.toLowerCase();
              final matchesSearch = p.name.toLowerCase().contains(query) ||
                  p.sku.toLowerCase().contains(query) ||
                  p.categoryName.toLowerCase().contains(query);

              bool matchesStock = true;
              if (_stockFilter == 'Low Stock') matchesStock = p.isLowStock;
              if (_stockFilter == 'Out of Stock') matchesStock = p.isOutOfStock;

              return matchesSearch && matchesStock;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeader(
                    title: 'Inventory & Stock Control',
                    subtitle: 'Audit product stock levels, valuation, and stock movement logs',
                  ),

                  // Valuation KPI Cards
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int count = constraints.maxWidth > 900 ? 4 : 2;
                      return GridView.count(
                        crossAxisCount: count,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 2.2,
                        children: [
                          StatCard(
                            title: 'Total Stock Units',
                            value: '$totalStockCount Items',
                            subtitle: '${products.length} unique products',
                            icon: Icons.inventory,
                            iconColor: AppColors.primary,
                            iconBgColor: AppColors.primary.withOpacity(0.12),
                          ),
                          StatCard(
                            title: 'Valuation (At Cost)',
                            value: 'Rs ${totalCostValuation.toStringAsFixed(2)}',
                            subtitle: 'Total purchase cost',
                            icon: Icons.account_balance,
                            iconColor: AppColors.info,
                            iconBgColor: AppColors.infoBg,
                          ),
                          StatCard(
                            title: 'Valuation (At Retail)',
                            value: 'Rs ${totalRetailValuation.toStringAsFixed(2)}',
                            subtitle: 'Expected sales value',
                            icon: Icons.store,
                            iconColor: AppColors.success,
                            iconBgColor: AppColors.successBg,
                          ),
                          StatCard(
                            title: 'Potential Profit',
                            value: 'Rs ${potentialProfit.toStringAsFixed(2)}',
                            subtitle: 'Retail minus cost',
                            icon: Icons.trending_up,
                            iconColor: AppColors.accent,
                            iconBgColor: AppColors.infoBg,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tabs: Stock Audit vs Movement Logs
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.primary,
                    tabs: [
                      Tab(text: 'Current Stock Audit (${products.length})'),
                      Tab(text: 'Stock Movement Logs (${movements.length})'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Current Stock Table
                        Column(
                          children: [
                            SearchAndFilterBar(
                              hintText: 'Search stock by Product, SKU, Category...',
                              onSearchChanged: (val) => setState(() => _searchQuery = val),
                              filterWidget: DropdownButtonFormField<String>(
                                value: _stockFilter,
                                decoration: const InputDecoration(labelText: 'Stock Filter', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                items: [
                                  const DropdownMenuItem(value: 'All', child: Text('All Stock')),
                                  DropdownMenuItem(value: 'Low Stock', child: Text('Low Stock (${lowStockProducts.length})')),
                                  DropdownMenuItem(value: 'Out of Stock', child: Text('Out of Stock (${outOfStockProducts.length})')),
                                ],
                                onChanged: (val) => setState(() => _stockFilter = val ?? 'All'),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: filteredProducts.isEmpty
                                  ? const EmptyStateWidget(
                                      icon: Icons.warehouse_outlined,
                                      title: 'No Inventory Items Found',
                                      description: 'All items match filters or no products are available.',
                                    )
                                  : Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: CustomDataTable(
                                          columns: const [
                                            DataTableColumn(label: 'Product'),
                                            DataTableColumn(label: 'SKU'),
                                            DataTableColumn(label: 'In Stock'),
                                            DataTableColumn(label: 'Min Level'),
                                            DataTableColumn(label: 'Cost Valuation', numeric: true),
                                            DataTableColumn(label: 'Retail Valuation', numeric: true),
                                            DataTableColumn(label: 'Status'),
                                            DataTableColumn(label: 'Action'),
                                          ],
                                          rows: filteredProducts.map((p) {
                                            final costVal = p.stock * p.purchasePrice;
                                            final retailVal = p.stock * p.sellingPrice;

                                            return [
                                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text(p.sku.isNotEmpty ? p.sku : 'N/A', style: const TextStyle(fontSize: 12)),
                                              Text('${p.stock} ${p.unit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                              Text('${p.minStock} ${p.unit}', style: const TextStyle(color: Colors.grey)),
                                              Text('Rs ${costVal.toStringAsFixed(2)}'),
                                              Text('Rs ${retailVal.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary)),
                                              p.isOutOfStock
                                                  ? StatusBadge.danger('Out of Stock')
                                                  : (p.isLowStock
                                                      ? StatusBadge.warning('Low Stock')
                                                      : StatusBadge.success('Sufficient')),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                                onPressed: () => _showAdjustStockModal(p),
                                                icon: const Icon(Icons.swap_vert, size: 16),
                                                label: const Text('Adjust', style: TextStyle(fontSize: 12)),
                                              ),
                                            ];
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        // Tab 2: Stock Movement Logs
                        movements.isEmpty
                            ? const EmptyStateWidget(
                                icon: Icons.history,
                                title: 'No Movement Logs Recorded',
                                description: 'Stock adjustments, purchases, and sales will log movement records automatically.',
                              )
                            : Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: CustomDataTable(
                                    columns: const [
                                      DataTableColumn(label: 'Date & Time'),
                                      DataTableColumn(label: 'Product Name'),
                                      DataTableColumn(label: 'Prev Stock'),
                                      DataTableColumn(label: 'Change'),
                                      DataTableColumn(label: 'New Stock'),
                                      DataTableColumn(label: 'Reason'),
                                      DataTableColumn(label: 'Operator'),
                                    ],
                                    rows: movements.map((m) {
                                      final isPositive = m.changeQuantity > 0;
                                      return [
                                        Text(DateFormat('dd MMM yyyy, hh:mm a').format(m.timestamp), style: const TextStyle(fontSize: 12)),
                                        Text(m.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text('${m.previousStock}'),
                                        Text(
                                          '${isPositive ? "+" : ""}${m.changeQuantity}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isPositive ? AppColors.success : AppColors.danger,
                                          ),
                                        ),
                                        Text('${m.newStock}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        StatusBadge.info(m.reason),
                                        Text(m.operatorName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ];
                                    }).toList(),
                                  ),
                                ),
                              ),
                      ],
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
