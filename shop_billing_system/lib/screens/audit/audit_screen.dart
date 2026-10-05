import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/search_and_filter_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_data_table.dart';
import '../../repositories/shop_repository.dart';
import '../../models/audit_log_model.dart';
import 'package:intl/intl.dart';

class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  final ShopRepository _repository = ShopRepository();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AuditLog>>(
      stream: _repository.auditLogsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading System Audit Trail...');
        }

        final logs = snapshot.data ?? [];
        final filteredLogs = logs.where((l) {
          final q = _searchQuery.toLowerCase();
          return l.action.toLowerCase().contains(q) ||
              l.details.toLowerCase().contains(q) ||
              l.module.toLowerCase().contains(q) ||
              l.user.toLowerCase().contains(q);
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'System Audit Trail & Security Logs',
                subtitle: 'Track all administrative operations, product edits, stock changes, sales, and payments',
              ),

              SearchAndFilterBar(
                hintText: 'Search audit logs by action, module, or user...',
                onSearchChanged: (val) => setState(() => _searchQuery = val),
              ),

              const SizedBox(height: 20),

              if (filteredLogs.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.assignment_outlined,
                  title: 'No Audit Logs Found',
                  description: 'System actions and user activity will be recorded here automatically.',
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomDataTable(
                      columns: const [
                        DataTableColumn(label: 'Timestamp'),
                        DataTableColumn(label: 'Module'),
                        DataTableColumn(label: 'Action'),
                        DataTableColumn(label: 'Details'),
                        DataTableColumn(label: 'Operator'),
                      ],
                      rows: filteredLogs.map((l) {
                        return [
                          Text(DateFormat('dd MMM yyyy, hh:mm a').format(l.timestamp), style: const TextStyle(fontSize: 12)),
                          StatusBadge.info(l.module),
                          Text(l.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(l.details, style: const TextStyle(fontSize: 12)),
                          Text(l.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
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
