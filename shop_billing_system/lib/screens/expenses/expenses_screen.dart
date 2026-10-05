import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../repositories/shop_repository.dart';
import '../../models/expense_model.dart';
import 'package:intl/intl.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ShopRepository _repository = ShopRepository();

  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _expenseCategories = [
    'Rent',
    'Electricity / Utilities',
    'Salaries & Wages',
    'Transport / Freight',
    'Shop Supplies',
    'Maintenance & Repair',
    'Marketing & Ads',
    'Other Expenses',
  ];

  void _showExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descController = TextEditingController();
    String category = _expenseCategories.first;
    String paymentMethod = 'Cash';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Shop Expense'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(labelText: 'Expense Category *', prefixIcon: Icon(Icons.category)),
                      items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) category = val;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount (Rs) *', prefixIcon: Icon(Icons.attach_money)),
                      validator: (val) {
                        if (val == null || double.tryParse(val) == null || double.parse(val) <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        return null;
                      },
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
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description / Notes', prefixIcon: Icon(Icons.note)),
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
                  final expense = Expense(
                    id: '',
                    category: category,
                    amount: double.parse(amountController.text.trim()),
                    date: DateTime.now(),
                    description: descController.text.trim(),
                    paymentMethod: paymentMethod,
                  );

                  await _repository.addExpense(expense);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save Expense'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _repository.expensesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading Expenses...');
        }

        final expenses = snapshot.data ?? [];
        final double totalExpenseAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);

        final filteredExpenses = expenses.where((e) {
          final q = _searchQuery.toLowerCase();
          final matchesSearch = e.category.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q);
          final matchesCat = _selectedCategory == 'All' || e.category == _selectedCategory;
          return matchesSearch && matchesCat;
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'Shop Expense Tracking',
                subtitle: 'Log operational expenses (rent, utilities, salaries) for accurate net profit calculation',
                actions: [
                  ElevatedButton.icon(
                    onPressed: _showExpenseDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Expense'),
                  ),
                ],
              ),

              // KPI Card
              SizedBox(
                width: 320,
                child: StatCard(
                  title: 'Total Expenses Logged',
                  value: 'Rs ${totalExpenseAmount.toStringAsFixed(2)}',
                  subtitle: '${expenses.length} expense entries',
                  icon: Icons.payments_outlined,
                  iconColor: AppColors.danger,
                  iconBgColor: AppColors.dangerBg,
                ),
              ),

              const SizedBox(height: 20),

              SearchAndFilterBar(
                hintText: 'Search expenses by category or note...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
                filterWidget: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  isDense: true,
                  decoration: const InputDecoration(labelText: 'Category', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                  items: [
                    const DropdownMenuItem(value: 'All', child: Text('All Categories')),
                    ..._expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val ?? 'All'),
                ),
              ),

              const SizedBox(height: 20),

              if (filteredExpenses.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Expenses Found',
                  description: 'Record shop utility bills, rent, and overheads to manage costs.',
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Date'),
                        DataTableColumn(label: 'Category'),
                        DataTableColumn(label: 'Description'),
                        DataTableColumn(label: 'Payment Method'),
                        DataTableColumn(label: 'Amount', numeric: true),
                        DataTableColumn(label: 'Action'),
                      ],
                      rows: filteredExpenses.map((e) {
                        return [
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(e.date), style: const TextStyle(fontSize: 12)),
                          Text(e.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(e.description.isNotEmpty ? e.description : 'No note'),
                          StatusBadge.info(e.paymentMethod),
                          Text('Rs ${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.danger)),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await ConfirmationDialog.show(
                                context,
                                title: 'Delete Expense',
                                message: 'Are you sure you want to delete this expense of Rs ${e.amount.toStringAsFixed(2)}?',
                              );
                              if (confirmed) {
                                await _repository.deleteExpense(e.id, e.category, e.amount);
                              }
                            },
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
