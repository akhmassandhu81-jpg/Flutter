import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../repositories/shop_repository.dart';
import '../../models/sale_model.dart';
import '../../models/product_model.dart';
import '../receipt/receipt_dialog.dart';
import 'package:intl/intl.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ShopRepository _repository = ShopRepository();

  String _searchQuery = '';
  String _dateFilter = 'All'; // Today, Yesterday, This Month, All

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _processReturn(Sale sale, List<Product> products) {
    final reasonController = TextEditingController(text: 'Customer Return / Damaged');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Process Sale Return: ${sale.invoiceNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Original Amount: Rs ${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('This will restore all items in this invoice back into inventory stock.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(labelText: 'Return Reason', prefixIcon: Icon(Icons.note)),
              ),
            ],
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                await _repository.processSaleReturn(
                  sale: sale,
                  currentProducts: products,
                  reason: reasonController.text.trim(),
                );
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Confirm Return & Restore Stock'),
            ),
          ],
        );
      },
    );
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
            if (!prodSnap.hasData || !saleSnap.hasData) {
              return const LoadingWidget(message: 'Loading Sales History...');
            }

            final products = prodSnap.data ?? [];
            final sales = saleSnap.data ?? [];

            final filteredSales = sales.where((s) {
              final q = _searchQuery.toLowerCase();
              final matchesQuery = s.invoiceNumber.toLowerCase().contains(q) ||
                  s.customerName.toLowerCase().contains(q);

              bool matchesDate = true;
              if (_dateFilter == 'Today') {
                matchesDate = _isSameDay(s.date, now);
              } else if (_dateFilter == 'Yesterday') {
                final yesterday = now.subtract(const Duration(days: 1));
                matchesDate = _isSameDay(s.date, yesterday);
              } else if (_dateFilter == 'This Month') {
                matchesDate = s.date.year == now.year && s.date.month == now.month;
              }

              return matchesQuery && matchesDate;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'Sales & Invoices History',
                    subtitle: 'Review completed transactions, receipts, customer bills, and sale returns',
                  ),

                  SearchAndFilterBar(
                    hintText: 'Search sales by Invoice # or Customer...',
                    onSearchChanged: (val) => setState(() => _searchQuery = val),
                    filterWidget: DropdownButtonFormField<String>(
                      value: _dateFilter,
                      decoration: const InputDecoration(labelText: 'Date Range', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Time')),
                        DropdownMenuItem(value: 'Today', child: Text('Today')),
                        DropdownMenuItem(value: 'Yesterday', child: Text('Yesterday')),
                        DropdownMenuItem(value: 'This Month', child: Text('This Month')),
                      ],
                      onChanged: (val) => setState(() => _dateFilter = val ?? 'All'),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (filteredSales.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'No Sales History Found',
                      description: 'Completed sales from the POS terminal will appear here.',
                    )
                  else
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomDataTable(
                          columns: const [
                            DataTableColumn(label: 'Invoice #'),
                            DataTableColumn(label: 'Date & Time'),
                            DataTableColumn(label: 'Customer'),
                            DataTableColumn(label: 'Payment Method'),
                            DataTableColumn(label: 'Total Amount', numeric: true),
                            DataTableColumn(label: 'Status'),
                            DataTableColumn(label: 'Actions'),
                          ],
                          rows: filteredSales.map((s) {
                            return [
                              Text(s.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(DateFormat('dd MMM yyyy, hh:mm a').format(s.date), style: const TextStyle(fontSize: 12)),
                              Text(s.customerName),
                              StatusBadge.info(s.paymentMethod),
                              Text('Rs ${s.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                              s.status == 'Returned'
                                  ? StatusBadge.danger('Returned')
                                  : StatusBadge.success('Completed'),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.receipt, size: 18, color: AppColors.primary),
                                    tooltip: 'View / Print Receipt',
                                    onPressed: () => ReceiptDialog.show(context, sale: s),
                                  ),
                                  if (s.status != 'Returned')
                                    IconButton(
                                      icon: const Icon(Icons.undo, size: 18, color: AppColors.danger),
                                      tooltip: 'Process Sale Return',
                                      onPressed: () => _processReturn(s, products),
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
