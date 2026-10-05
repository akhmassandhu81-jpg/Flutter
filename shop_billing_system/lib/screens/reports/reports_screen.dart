import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../repositories/shop_repository.dart';
import '../../models/sale_model.dart';
import '../../models/expense_model.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  final ShopRepository _repository = ShopRepository();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return StreamBuilder<List<Product>>(
      stream: _repository.productsStream,
      builder: (context, prodSnap) {
        return StreamBuilder<List<Sale>>(
          stream: _repository.salesStream,
          builder: (context, saleSnap) {
            return StreamBuilder<List<Expense>>(
              stream: _repository.expensesStream,
              builder: (context, expSnap) {
                if (!prodSnap.hasData || !saleSnap.hasData || !expSnap.hasData) {
                  return const LoadingWidget(message: 'Generating Financial Reports...');
                }

                final sales = saleSnap.data ?? [];
                final expenses = expSnap.data ?? [];
                final products = prodSnap.data ?? [];

                // Valid sales excluding returns
                final validSales = sales.where((s) => s.status != 'Returned').toList();

                // Revenue calculations
                final double totalRevenue = validSales.fold(0.0, (sum, s) => sum + s.totalAmount);
                final double totalCOGS = validSales.fold(0.0, (sum, s) => sum + s.totalCost);
                final double grossProfit = totalRevenue - totalCOGS;

                final double totalExpenses = expenses.fold(0.0, (sum, e) => sum + e.amount);
                final double netProfit = grossProfit - totalExpenses;
                final double profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

                // Today, Monthly, Annual Revenue
                final todaySales = validSales.where((s) => _isSameDay(s.date, now)).toList();
                final double todayRevenue = todaySales.fold(0.0, (sum, s) => sum + s.totalAmount);

                final monthlySales = validSales.where((s) => s.date.year == now.year && s.date.month == now.month).toList();
                final double monthlyRevenue = monthlySales.fold(0.0, (sum, s) => sum + s.totalAmount);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageHeader(
                        title: 'Reports & Financial Analytics',
                        subtitle: 'Comprehensive business income statements, profit & loss, and sales performance',
                      ),

                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: 'Profit & Loss Statement'),
                          Tab(text: 'Sales Performance'),
                          Tab(text: 'Product Performance'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 600,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Tab 1: P&L Statement
                            _buildProfitAndLossTab(
                              totalRevenue: totalRevenue,
                              totalCOGS: totalCOGS,
                              grossProfit: grossProfit,
                              totalExpenses: totalExpenses,
                              netProfit: netProfit,
                              profitMargin: profitMargin,
                            ),

                            // Tab 2: Sales Summary
                            _buildSalesSummaryTab(
                              todayRevenue: todayRevenue,
                              todayCount: todaySales.length,
                              monthlyRevenue: monthlyRevenue,
                              monthlyCount: monthlySales.length,
                              allSales: validSales,
                            ),

                            // Tab 3: Top Selling Products
                            _buildProductPerformanceTab(validSales, products),
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
      },
    );
  }

  Widget _buildProfitAndLossTab({
    required double totalRevenue,
    required double totalCOGS,
    required double grossProfit,
    required double totalExpenses,
    required double netProfit,
    required double profitMargin,
  }) {
    return Column(
      children: [
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
                  title: 'Total Revenue (Sales)',
                  value: 'Rs ${totalRevenue.toStringAsFixed(2)}',
                  subtitle: 'Gross sales income',
                  icon: Icons.payments,
                  iconColor: AppColors.primary,
                  iconBgColor: AppColors.primary.withOpacity(0.12),
                ),
                StatCard(
                  title: 'Cost of Goods Sold (COGS)',
                  value: 'Rs ${totalCOGS.toStringAsFixed(2)}',
                  subtitle: 'Product purchase cost',
                  icon: Icons.shopping_bag,
                  iconColor: AppColors.accent,
                  iconBgColor: AppColors.infoBg,
                ),
                StatCard(
                  title: 'Gross Profit',
                  value: 'Rs ${grossProfit.toStringAsFixed(2)}',
                  subtitle: 'Revenue minus COGS',
                  icon: Icons.show_chart,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successBg,
                ),
                StatCard(
                  title: 'Total Operating Expenses',
                  value: 'Rs ${totalExpenses.toStringAsFixed(2)}',
                  subtitle: 'Rent, utilities, salaries',
                  icon: Icons.money_off,
                  iconColor: AppColors.danger,
                  iconBgColor: AppColors.dangerBg,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Net Profit & Income Statement Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Divider(height: 24),

                _buildPnlLineItem('Gross Revenue (Sales)', totalRevenue, isPositive: true),
                _buildPnlLineItem('Cost of Goods Sold (COGS)', -totalCOGS, isPositive: false),
                const Divider(),
                _buildPnlLineItem('GROSS PROFIT', grossProfit, isBold: true, isPositive: grossProfit >= 0),
                const SizedBox(height: 8),
                _buildPnlLineItem('Less: Shop Expenses', -totalExpenses, isPositive: false),
                const Divider(thickness: 2),
                _buildPnlLineItem('NET BUSINESS PROFIT', netProfit, isBold: true, fontSize: 18, isPositive: netProfit >= 0),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Profit Margin Percentage:'),
                    Text('${profitMargin.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPnlLineItem(String label, double amount, {bool isBold = false, double fontSize = 14, bool isPositive = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            'Rs ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isPositive ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesSummaryTab({
    required double todayRevenue,
    required int todayCount,
    required double monthlyRevenue,
    required int monthlyCount,
    required List<Sale> allSales,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: "Today's Sales Revenue",
                value: 'Rs ${todayRevenue.toStringAsFixed(2)}',
                subtitle: '$todayCount transactions today',
                icon: Icons.today,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primary.withOpacity(0.12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'This Month Revenue',
                value: 'Rs ${monthlyRevenue.toStringAsFixed(2)}',
                subtitle: '$monthlyCount sales this month',
                icon: Icons.calendar_month,
                iconColor: AppColors.accent,
                iconBgColor: AppColors.infoBg,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Invoice #'),
                  DataTableColumn(label: 'Date'),
                  DataTableColumn(label: 'Customer'),
                  DataTableColumn(label: 'Items Sold'),
                  DataTableColumn(label: 'Total Amount', numeric: true),
                ],
                rows: allSales.map((s) {
                  return [
                    Text(s.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('dd MMM yyyy, hh:mm a').format(s.date), style: const TextStyle(fontSize: 12)),
                    Text(s.customerName),
                    Text('${s.items.length} items'),
                    Text('Rs ${s.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ];
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductPerformanceTab(List<Sale> sales, List<Product> products) {
    // Calculate total quantity sold per product
    final Map<String, int> productQtyMap = {};
    final Map<String, double> productRevenueMap = {};

    for (var sale in sales) {
      for (var item in sale.items) {
        productQtyMap[item.name] = (productQtyMap[item.name] ?? 0) + item.quantity;
        productRevenueMap[item.name] = (productRevenueMap[item.name] ?? 0.0) + item.total;
      }
    }

    final sortedItems = productQtyMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Selling Products by Volume & Revenue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: sortedItems.isEmpty
                  ? const Center(child: Text('No sales performance data available yet.'))
                  : CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Rank'),
                        DataTableColumn(label: 'Product Name'),
                        DataTableColumn(label: 'Units Sold', numeric: true),
                        DataTableColumn(label: 'Total Revenue Generated', numeric: true),
                      ],
                      rows: sortedItems.asMap().entries.map((entry) {
                        final rank = entry.key + 1;
                        final name = entry.value.key;
                        final qty = entry.value.value;
                        final rev = productRevenueMap[name] ?? 0.0;

                        return [
                          Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text('$qty units'),
                          Text('Rs ${rev.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ];
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
