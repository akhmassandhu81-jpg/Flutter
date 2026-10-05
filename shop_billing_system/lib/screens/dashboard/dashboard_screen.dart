import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/loading_widget.dart';
import '../../repositories/shop_repository.dart';
import '../../models/product_model.dart';
import '../../models/sale_model.dart';
import '../../models/purchase_model.dart';
import '../../models/customer_model.dart';
import '../../models/supplier_model.dart';
import '../../models/expense_model.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  DashboardScreen({super.key, required this.onNavigate});

  final ShopRepository _repository = ShopRepository();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return StreamBuilder<List<Product>>(
      stream: _repository.productsStream,
      builder: (context, productsSnap) {
        return StreamBuilder<List<Sale>>(
          stream: _repository.salesStream,
          builder: (context, salesSnap) {
            return StreamBuilder<List<Purchase>>(
              stream: _repository.purchasesStream,
              builder: (context, purchasesSnap) {
                return StreamBuilder<List<Customer>>(
                  stream: _repository.customersStream,
                  builder: (context, customersSnap) {
                    return StreamBuilder<List<Supplier>>(
                      stream: _repository.suppliersStream,
                      builder: (context, suppliersSnap) {
                        return StreamBuilder<List<Expense>>(
                          stream: _repository.expensesStream,
                          builder: (context, expensesSnap) {
                            if (!productsSnap.hasData || !salesSnap.hasData) {
                              return const LoadingWidget(message: 'Loading Dashboard Metrics...');
                            }

                            final products = productsSnap.data ?? [];
                            final sales = salesSnap.data ?? [];
                            final purchases = purchasesSnap.data ?? [];
                            final customers = customersSnap.data ?? [];
                            final suppliers = suppliersSnap.data ?? [];
                            final expenses = expensesSnap.data ?? [];

                            // Calculates
                            final todaySalesList = sales.where((s) => _isSameDay(s.date, now) && s.status != 'Returned').toList();
                            final double todaySalesTotal = todaySalesList.fold(0.0, (sum, s) => sum + s.totalAmount);

                            final todayPurchasesList = purchases.where((p) => _isSameDay(p.date, now)).toList();
                            final double todayPurchasesTotal = todayPurchasesList.fold(0.0, (sum, p) => sum + p.totalAmount);

                            final todayExpensesList = expenses.where((e) => _isSameDay(e.date, now)).toList();
                            final double todayExpensesTotal = todayExpensesList.fold(0.0, (sum, e) => sum + e.amount);

                            // Today's Gross Profit = Today Revenue - Today COGS
                            final double todayCOGS = todaySalesList.fold(0.0, (sum, s) => sum + s.totalCost);
                            final double todayGrossProfit = todaySalesTotal - todayCOGS;
                            final double todayNetProfit = todayGrossProfit - todayExpensesTotal;

                            final lowStockProducts = products.where((p) => p.isLowStock).toList();
                            final outOfStockProducts = products.where((p) => p.isOutOfStock).toList();

                            final double totalReceivables = customers.fold(0.0, (sum, c) => sum + c.currentBalance);
                            final double totalPayables = suppliers.fold(0.0, (sum, sup) => sum + sup.currentBalance);

                            return SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  PageHeader(
                                    title: 'Shop Overview',
                                    subtitle: 'Real-time performance metrics for ${DateFormat('EEEE, dd MMMM yyyy').format(now)}',
                                    actions: [
                                      ElevatedButton.icon(
                                        onPressed: () => onNavigate(1), // POS
                                        icon: const Icon(Icons.point_of_sale, size: 18),
                                        label: const Text('Open POS Terminal'),
                                      ),
                                    ],
                                  ),

                                  // KPI Grid
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      int crossAxisCount = constraints.maxWidth > 1200
                                          ? 4
                                          : (constraints.maxWidth > 700 ? 2 : 1);

                                      return GridView.count(
                                        crossAxisCount: crossAxisCount,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 2.3,
                                        children: [
                                          StatCard(
                                            title: "Today's Sales",
                                            value: 'Rs ${todaySalesTotal.toStringAsFixed(2)}',
                                            subtitle: '${todaySalesList.length} transactions today',
                                            icon: Icons.payments,
                                            iconColor: AppColors.success,
                                            iconBgColor: AppColors.successBg,
                                            onTap: () => onNavigate(8),
                                          ),
                                          StatCard(
                                            title: "Today's Purchases",
                                            value: 'Rs ${todayPurchasesTotal.toStringAsFixed(2)}',
                                            subtitle: '${todayPurchasesList.length} POs created',
                                            icon: Icons.shopping_cart,
                                            iconColor: AppColors.accent,
                                            iconBgColor: AppColors.infoBg,
                                            onTap: () => onNavigate(5),
                                          ),
                                          StatCard(
                                            title: "Today's Net Profit",
                                            value: 'Rs ${todayNetProfit.toStringAsFixed(2)}',
                                            subtitle: 'Revenue - COGS - Expenses',
                                            icon: Icons.trending_up,
                                            iconColor: todayNetProfit >= 0 ? AppColors.primary : AppColors.danger,
                                            iconBgColor: AppColors.primary.withOpacity(0.12),
                                            onTap: () => onNavigate(10),
                                          ),
                                          StatCard(
                                            title: 'Active Products',
                                            value: '${products.where((p) => p.isActive).length}',
                                            subtitle: '${lowStockProducts.length + outOfStockProducts.length} low/out of stock',
                                            icon: Icons.inventory_2,
                                            iconColor: AppColors.info,
                                            iconBgColor: AppColors.infoBg,
                                            onTap: () => onNavigate(2),
                                          ),
                                          StatCard(
                                            title: 'Customer Receivables',
                                            value: 'Rs ${totalReceivables.toStringAsFixed(2)}',
                                            subtitle: 'Pending customer credits',
                                            icon: Icons.account_balance_wallet,
                                            iconColor: AppColors.warning,
                                            iconBgColor: AppColors.warningBg,
                                            onTap: () => onNavigate(7),
                                          ),
                                          StatCard(
                                            title: 'Supplier Payables',
                                            value: 'Rs ${totalPayables.toStringAsFixed(2)}',
                                            subtitle: 'Pending supplier payables',
                                            icon: Icons.request_quote,
                                            iconColor: AppColors.danger,
                                            iconBgColor: AppColors.dangerBg,
                                            onTap: () => onNavigate(6),
                                          ),
                                          StatCard(
                                            title: 'Low Stock Items',
                                            value: '${lowStockProducts.length}',
                                            subtitle: 'Requires reorder soon',
                                            icon: Icons.warning_amber_rounded,
                                            iconColor: AppColors.warning,
                                            iconBgColor: AppColors.warningBg,
                                            onTap: () => onNavigate(4),
                                          ),
                                          StatCard(
                                            title: 'Out of Stock',
                                            value: '${outOfStockProducts.length}',
                                            subtitle: 'Needs immediate restock',
                                            icon: Icons.error_outline,
                                            iconColor: AppColors.danger,
                                            iconBgColor: AppColors.dangerBg,
                                            onTap: () => onNavigate(4),
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 24),

                                  // Quick Action Cards
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickActionButton(
                                          context,
                                          title: 'New POS Sale',
                                          icon: Icons.point_of_sale,
                                          color: AppColors.primary,
                                          onTap: () => onNavigate(1),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildQuickActionButton(
                                          context,
                                          title: 'Adjust Stock',
                                          icon: Icons.swap_vert,
                                          color: AppColors.accent,
                                          onTap: () => onNavigate(4),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildQuickActionButton(
                                          context,
                                          title: 'New Purchase',
                                          icon: Icons.add_shopping_cart,
                                          color: AppColors.info,
                                          onTap: () => onNavigate(5),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildQuickActionButton(
                                          context,
                                          title: 'Add Expense',
                                          icon: Icons.receipt_long,
                                          color: AppColors.warning,
                                          onTap: () => onNavigate(9),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Two Columns Layout: Low Stock Warning + Recent Sales
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      bool isWide = constraints.maxWidth > 900;

                                      return isWide
                                          ? Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: _buildRecentSalesCard(context, sales),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  flex: 2,
                                                  child: _buildLowStockCard(context, lowStockProducts, outOfStockProducts),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                _buildRecentSalesCard(context, sales),
                                                const SizedBox(height: 20),
                                                _buildLowStockCard(context, lowStockProducts, outOfStockProducts),
                                              ],
                                            );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSalesCard(BuildContext context, List<Sale> sales) {
    final recent = sales.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recent Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => onNavigate(8),
                  child: const Text('View All'),
                ),
              ],
            ),
            const Divider(height: 20),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: Text('No sales recorded yet.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final sale = recent[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: sale.status == 'Returned' ? AppColors.dangerBg : AppColors.successBg,
                      child: Icon(
                        sale.status == 'Returned' ? Icons.undo : Icons.receipt,
                        color: sale.status == 'Returned' ? AppColors.danger : AppColors.success,
                        size: 20,
                      ),
                    ),
                    title: Text('${sale.invoiceNumber} - ${sale.customerName}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(DateFormat('dd MMM, hh:mm a').format(sale.date), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Rs ${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        StatusBadge(
                          label: sale.status,
                          backgroundColor: sale.status == 'Returned' ? AppColors.dangerBg : AppColors.successBg,
                          textColor: sale.status == 'Returned' ? AppColors.danger : AppColors.success,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockCard(BuildContext context, List<Product> lowStock, List<Product> outOfStock) {
    final alertProducts = [...outOfStock, ...lowStock];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Low / Out of Stock Alert', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => onNavigate(4),
                  child: const Text('Manage Stock'),
                ),
              ],
            ),
            const Divider(height: 20),
            if (alertProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text('All products have adequate stock!'),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alertProducts.length > 5 ? 5 : alertProducts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final p = alertProducts[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    subtitle: Text('Category: ${p.categoryName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StatusBadge(
                          label: p.isOutOfStock ? 'Out of Stock (${p.stock})' : 'Low Stock (${p.stock})',
                          backgroundColor: p.isOutOfStock ? AppColors.dangerBg : AppColors.warningBg,
                          textColor: p.isOutOfStock ? AppColors.danger : AppColors.warning,
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
