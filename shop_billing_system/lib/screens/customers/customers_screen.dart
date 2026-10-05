import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../providers/customer_notifier.dart';
import '../../models/customer_model.dart';
import 'package:intl/intl.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchQuery = '';

  void _showCustomerDialog([Customer? existingCustomer]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: existingCustomer?.name ?? '');
    final phoneController = TextEditingController(text: existingCustomer?.phone ?? '');
    final emailController = TextEditingController(text: existingCustomer?.email ?? '');
    final addressController = TextEditingController(text: existingCustomer?.address ?? '');
    final notesController = TextEditingController(text: existingCustomer?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(existingCustomer == null ? 'Add New Customer' : 'Edit Customer'),
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
                      decoration: const InputDecoration(labelText: 'Customer Name *', prefixIcon: Icon(Icons.person)),
                      validator: (val) => (val == null || val.trim().isEmpty) ? 'Name is required' : null,
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(labelText: 'Notes', prefixIcon: Icon(Icons.note)),
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
                  final customer = Customer(
                    id: existingCustomer?.id ?? '',
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    email: emailController.text.trim(),
                    address: addressController.text.trim(),
                    notes: notesController.text.trim(),
                    currentBalance: existingCustomer?.currentBalance ?? 0.0,
                    totalPurchases: existingCustomer?.totalPurchases ?? 0.0,
                    lastPurchaseDate: existingCustomer?.lastPurchaseDate,
                    createdAt: existingCustomer?.createdAt,
                  );

                  if (existingCustomer == null) {
                    await ref.read(customerNotifierProvider.notifier).addCustomer(customer);
                  } else {
                    await ref.read(customerNotifierProvider.notifier).updateCustomer(customer);
                  }

                  if (mounted) Navigator.pop(context);
                }
              },
              child: Text(existingCustomer == null ? 'Save Customer' : 'Update Customer'),
            ),
          ],
        );
      },
    );
  }

  void _showRecordPaymentDialog(Customer customer) {
    final amountController = TextEditingController();
    final notesController = TextEditingController(text: 'Payment received');
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Receive Payment: ${customer.name}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.warningBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Outstanding Receivable:'),
                      Text('Rs ${customer.currentBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.warning)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount Received (Rs) *', prefixIcon: Icon(Icons.payments)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method', prefixIcon: Icon(Icons.account_balance)),
                  items: const [
                    DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                    DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                    DropdownMenuItem(value: 'Card', child: Text('Card')),
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
                  await ref.read(customerNotifierProvider.notifier).recordPayment(
                        customerId: customer.id,
                        customerName: customer.name,
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
    final customersAsync = ref.watch(customerNotifierProvider);

    return customersAsync.when(
      loading: () => const AppLoadingState(message: 'Loading Customers...'),
      error: (err, st) => AppErrorState(message: err.toString(), onRetry: () => ref.refresh(customerNotifierProvider)),
      data: (customers) {
        final filteredCustomers = customers.where((c) {
          final q = _searchQuery.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
              c.phone.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q);
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Customer Profiles & Credit Accounts',
                subtitle: 'Manage client contacts, sale histories, and outstanding customer credit balances',
                actions: [
                  ElevatedButton.icon(
                    onPressed: () => _showCustomerDialog(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Customer'),
                  ),
                ],
              ),

              SearchAndFilterBar(
                hintText: 'Search customers by name, phone, or email...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
              ),

              const SizedBox(height: 20),

              if (filteredCustomers.isEmpty)
                EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: 'No Customers Found',
                  description: 'Add customers to record sales on credit or track purchase history.',
                  actionLabel: 'Add Customer',
                  onAction: () => _showCustomerDialog(),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Customer Name'),
                        DataTableColumn(label: 'Phone'),
                        DataTableColumn(label: 'Email'),
                        DataTableColumn(label: 'Total Purchases', numeric: true),
                        DataTableColumn(label: 'Receivable Credit', numeric: true),
                        DataTableColumn(label: 'Last Purchase'),
                        DataTableColumn(label: 'Actions'),
                      ],
                      rows: filteredCustomers.map((c) {
                        return [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(c.phone.isNotEmpty ? c.phone : 'N/A'),
                          Text(c.email.isNotEmpty ? c.email : 'N/A'),
                          Text('Rs ${c.totalPurchases.toStringAsFixed(2)}'),
                          Text('Rs ${c.currentBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                          Text(c.lastPurchaseDate != null ? DateFormat('dd MMM yyyy').format(c.lastPurchaseDate!) : 'Never', style: const TextStyle(fontSize: 12)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (c.currentBalance > 0)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                                  onPressed: () => _showRecordPaymentDialog(c),
                                  icon: const Icon(Icons.payments, size: 14),
                                  label: const Text('Receive', style: TextStyle(fontSize: 12)),
                                ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18, color: AppColors.info),
                                onPressed: () => _showCustomerDialog(c),
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
