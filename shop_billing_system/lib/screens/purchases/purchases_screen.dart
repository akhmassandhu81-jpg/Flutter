import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../repositories/shop_repository.dart';
import '../../models/purchase_model.dart';
import '../../models/supplier_model.dart';
import '../../models/product_model.dart';
import 'package:intl/intl.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final ShopRepository _repository = ShopRepository();
  String _searchQuery = '';

  void _showCreatePurchaseDialog(List<Supplier> suppliers, List<Product> products) {
    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one supplier before creating a purchase!'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final invoiceNumController = TextEditingController(text: 'PUR-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}');
    Supplier selectedSupplier = suppliers.first;

    List<PurchaseItem> purchaseItems = [];
    Product? selectedProduct = products.isNotEmpty ? products.first : null;
    final qtyController = TextEditingController(text: '10');
    final costPriceController = TextEditingController(text: selectedProduct?.purchasePrice.toString() ?? '100');
    final paidAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            double totalAmount = purchaseItems.fold(0.0, (sum, i) => sum + i.total);
            double paid = double.tryParse(paidAmountController.text.trim()) ?? totalAmount;
            double remaining = totalAmount > paid ? totalAmount - paid : 0.0;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Create New Purchase Order'),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<Supplier>(
                              value: selectedSupplier,
                              decoration: const InputDecoration(labelText: 'Supplier *', prefixIcon: Icon(Icons.local_shipping)),
                              items: suppliers.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                              onChanged: (val) {
                                if (val != null) setDialogState(() => selectedSupplier = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: invoiceNumController,
                              decoration: const InputDecoration(labelText: 'Purchase Invoice #', prefixIcon: Icon(Icons.receipt)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Text('Add Products to Purchase Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<Product>(
                                value: selectedProduct,
                                hint: const Text('Select Product'),
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                                items: products.map((p) => DropdownMenuItem(value: p, child: Text(p.name))).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setDialogState(() {
                                      selectedProduct = val;
                                      costPriceController.text = val.purchasePrice.toString();
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Qty', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 90,
                              child: TextField(
                                controller: costPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Cost/Unit', contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                              onPressed: () {
                                if (selectedProduct != null) {
                                  final q = int.tryParse(qtyController.text) ?? 1;
                                  final cost = double.tryParse(costPriceController.text) ?? 0.0;
                                  setDialogState(() {
                                    purchaseItems.add(PurchaseItem(
                                      productId: selectedProduct!.id,
                                      name: selectedProduct!.name,
                                      unitPrice: cost,
                                      quantity: q,
                                    ));
                                  });
                                }
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Purchase Items Table
                      if (purchaseItems.isNotEmpty)
                        Column(
                          children: purchaseItems.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return ListTile(
                              dense: true,
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${item.quantity} units x Rs ${item.unitPrice.toStringAsFixed(2)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Rs ${item.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                    onPressed: () => setDialogState(() => purchaseItems.removeAt(idx)),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const Divider(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: paidAmountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Paid Amount (Rs)', prefixIcon: Icon(Icons.payments)),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total: Rs ${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                              if (remaining > 0)
                                Text('Remaining Payable: Rs ${remaining.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.danger, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: purchaseItems.isEmpty
                      ? null
                      : () async {
                          final purchase = Purchase(
                            id: '',
                            purchaseInvoiceNumber: invoiceNumController.text.trim(),
                            date: DateTime.now(),
                            supplierId: selectedSupplier.id,
                            supplierName: selectedSupplier.name,
                            items: purchaseItems,
                            totalAmount: totalAmount,
                            paidAmount: paid,
                            remainingBalance: remaining,
                          );

                          await _repository.addPurchase(
                            purchase: purchase,
                            currentProducts: products,
                          );

                          if (mounted) Navigator.pop(context);
                        },
                  child: const Text('Submit Purchase & Increase Stock'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Supplier>>(
      stream: _repository.suppliersStream,
      builder: (context, supSnap) {
        return StreamBuilder<List<Product>>(
          stream: _repository.productsStream,
          builder: (context, prodSnap) {
            return StreamBuilder<List<Purchase>>(
              stream: _repository.purchasesStream,
              builder: (context, purSnap) {
                if (!supSnap.hasData || !prodSnap.hasData || !purSnap.hasData) {
                  return const LoadingWidget(message: 'Loading Purchases...');
                }

                final suppliers = supSnap.data ?? [];
                final products = prodSnap.data ?? [];
                final purchases = purSnap.data ?? [];

                final filteredPurchases = purchases.where((p) {
                  final q = _searchQuery.toLowerCase();
                  return p.purchaseInvoiceNumber.toLowerCase().contains(q) ||
                      p.supplierName.toLowerCase().contains(q);
                }).toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PageHeader(
                        title: 'Purchase Management',
                        subtitle: 'Record stock purchases, vendor bills, and automatic inventory increments',
                        actions: [
                          ElevatedButton.icon(
                            onPressed: () => _showCreatePurchaseDialog(suppliers, products),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('New Purchase Order'),
                          ),
                        ],
                      ),

                      SearchAndFilterBar(
                        hintText: 'Search purchases by Invoice # or Supplier...',
                        onSearchChanged: (val) => setState(() => _searchQuery = val),
                      ),

                      const SizedBox(height: 20),

                      if (filteredPurchases.isEmpty)
                        const EmptyStateWidget(
                          icon: Icons.shopping_bag_outlined,
                          title: 'No Purchases Recorded',
                          description: 'Create purchase orders to restock inventory from suppliers.',
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CustomDataTable(
                              columns: const [
                                DataTableColumn(label: 'Invoice #'),
                                DataTableColumn(label: 'Date'),
                                DataTableColumn(label: 'Supplier'),
                                DataTableColumn(label: 'Items Count'),
                                DataTableColumn(label: 'Total Amount', numeric: true),
                                DataTableColumn(label: 'Paid Amount', numeric: true),
                                DataTableColumn(label: 'Status'),
                              ],
                              rows: filteredPurchases.map((p) {
                                return [
                                  Text(p.purchaseInvoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(DateFormat('dd MMM yyyy, hh:mm a').format(p.date), style: const TextStyle(fontSize: 12)),
                                  Text(p.supplierName),
                                  Text('${p.items.length} Products'),
                                  Text('Rs ${p.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Rs ${p.paidAmount.toStringAsFixed(2)}'),
                                  p.paymentStatus == 'Paid'
                                      ? StatusBadge.success('Paid')
                                      : (p.paymentStatus == 'Partial'
                                          ? StatusBadge.warning('Partial')
                                          : StatusBadge.danger('Pending')),
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
      },
    );
  }
}
