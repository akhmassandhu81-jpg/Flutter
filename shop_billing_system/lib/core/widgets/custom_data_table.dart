import 'package:flutter/material.dart';

class DataTableColumn {
  final String label;
  final bool numeric;
  final double? width;

  const DataTableColumn({
    required this.label,
    this.numeric = false,
    this.width,
  });
}

class CustomDataTable extends StatelessWidget {
  final List<DataTableColumn> columns;
  final List<List<Widget>> rows;
  final bool isLoading;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          ),
          dataRowMinHeight: 52,
          dataRowMaxHeight: 64,
          headingRowHeight: 48,
          dividerThickness: 1,
          columns: columns.map((col) {
            return DataColumn(
              numeric: col.numeric,
              label: Text(
                col.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          rows: rows.map((rowCells) {
            return DataRow(
              cells: rowCells.map((cell) => DataCell(cell)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
