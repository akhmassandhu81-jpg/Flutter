import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../providers/supplier_notifier.dart';
import '../../models/supplier_model.dart';

class SuppliersScreen extends ConsumerStatefulWidget {
  const SuppliersScreen({super.key});

  @override
  ConsumerState<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends ConsumerState<SuppliersScreen> {
  String _searchQuery = '';

  void _showSupplierDialog([Supplier? existingSupplier]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingSupplier?.name ?? '');
    final companyController = TextEditingController(text: existingSupplier?.companyName ?? '');
    final phoneController = TextEditingController(text: existingSupplier?.phone ?? '');
    final emailController = TextEditingController(text: existingSupplier?.email ?? '');
    final addressController = TextEditingController(text: existingSupplier?.address ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existingSupplier == null ? 'Add New Supplier' : 'Edit Supplier'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Contact Name *', prefixIcon: Icon(Icons.person)),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: companyController,
                      decoration: const InputDecoration(labelText: 'Company / Business Name', prefixIcon: Icon(Icons.business)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final supplier = Supplier(
                    id: existingSupplier?.id ?? '',
                    name: nameController.text.trim(),
                    companyName: companyController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    currentBalance: existingSupplier?.currentBalance ?? 0.0,
                    createdAt: existingSupplier?.createdAt,
                  );

                  if (existingSupplier == null) {
                    await ref.read(supplierNotifierProvider.notifier).addSupplier(supplier);
                  } else {
                    await ref.read(supplierNotifierProvider.notifier).updateSupplier(supplier);
                  }

                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(existingSupplier == null ? 'Save Supplier' : 'Update Supplier'),
            ),
          ],
        );
      },
    );
  }

  void _showRecordPaymentDialog(Supplier supplier) {
    final amountController = TextEditingController();
    final notesController = TextEditingController(text: 'Payment to supplier');
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Pay Supplier: ${supplier.name}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Payable:'),
                      Text('Rs ${supplier.currentBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.danger)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount Paid (Rs) *', prefixIcon: Icon(Icons.payments)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method', prefixIcon: Icon(Icons.account_balance)),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Cheque', child: Text('Cheque')),
                  ],
                  onChanged: (val) {
                    if (val != null) paymentMethod = val;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.note)),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final amt = double.tryParse(amountController.text.trim());
                if (amt != null && amt > 0) {
                  await ref.read(supplierNotifierProvider.notifier).recordPayment(
                        supplierId: supplier.id,
                        supplierName: supplier.name,
                        amount: amt,
                        paymentMethod: paymentMethod,
                        notes: notesController.text.trim(),
                      );
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Record Payment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(supplierNotifierProvider);

    return suppliersAsync.when(
      loading: () => const AppLoadingState(message: 'Loading Suppliers...'),
      error: (err, st) => AppErrorState(message: err.toString(), onRetry: () => ref.refresh(supplierNotifierProvider)),
      data: (suppliers) {
        final filteredSuppliers = suppliers.where((s) {
          final q = _searchQuery.toLowerCase();
          return s.name.toLowerCase().contains(q) ||
              s.companyName.toLowerCase().contains(q) ||
              s.phone.toLowerCase().contains(q);
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Supplier Directory & Payables',
                subtitle: 'Manage vendors, purchase sources, and outstanding balance payables',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showSupplierDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Supplier'),
                  ),
                ],
              ),

              SearchAndFilterBar(
                hintText: 'Search suppliers by name, company, or phone...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
              ),

              const SizedBox(height: 20),

              if (filteredSuppliers.isEmpty)
                EmptyStateWidget(
                  icon: Icons.local_shipping_outlined,
                  title: 'No Suppliers Found',
                  description: 'Add vendors and suppliers to track goods purchases and payables.',
                  actionLabel: 'Add Supplier',
                  onAction: () => _showSupplierDialog(),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Supplier Name'),
                        DataTableColumn(label: 'Company'),
                        DataTableColumn(label: 'Phone'),
                        DataTableColumn(label: 'Email'),
                        DataTableColumn(label: 'Payable Balance', numeric: true),
                        DataTableColumn(label: 'Status'),
                        DataTableColumn(label: 'Actions'),
                      ],
                      rows: filteredSuppliers.map((s) {
                        return [
                          Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(s.companyName.isNotEmpty ? s.companyName : 'N/A'),
                          Text(s.phone.isNotEmpty ? s.phone : 'N/A'),
                          Text(s.email.isNotEmpty ? s.email : 'N/A'),
                          Text('Rs ${s.currentBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                          s.currentBalance > 0
                              ? StatusBadge.danger('Payable Due')
                              : StatusBadge.success('Clear'),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (s.currentBalance > 0)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                  onPressed: () => _showRecordPaymentDialog(s),
                                  icon: const Icon(Icons.payments, size: 14),
                                  label: const Text('Pay', style: TextStyle(fontSize: 12)),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.info),
                                onPressed: () => _showSupplierDialog(s),
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
  }
}
