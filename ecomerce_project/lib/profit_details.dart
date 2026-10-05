import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfitDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> profitItems;

  const ProfitDetailsPage({super.key, required this.profitItems});

  @override
  State<ProfitDetailsPage> createState() => _ProfitDetailsPageState();
}

class _ProfitDetailsPageState extends State<ProfitDetailsPage> {
  DateTimeRange? _selectedDateRange;
  final List<String> _filterOptions = ['All', 'Daily', 'Monthly', 'Annual', 'Custom Range'];
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profit Details"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          _buildFilterControls(),
          Expanded(
            child: _buildProfitList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedFilter,
              items: _filterOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFilter = newValue!;
                  if (_selectedFilter != 'Custom Range') {
                    _selectedDateRange = null;
                  }
                });
              },
            ),
            if (_selectedFilter == 'Custom Range')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDateRange(context),
                        child: Text(
                          _selectedDateRange == null
                              ? 'Select Date Range'
                              : '${DateFormat('MMM d, yyyy').format(_selectedDateRange!.start)} - '
                              '${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  Widget _buildProfitList() {
    List<Map<String, dynamic>> filteredItems = [];

    switch (_selectedFilter) {
      case 'Daily':
        filteredItems = _filterByDateRange(DateTime.now(), DateTime.now());
        break;
      case 'Monthly':
        final now = DateTime.now();
        filteredItems = _filterByDateRange(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0),
        );
        break;
      case 'Annual':
        final now = DateTime.now();
        filteredItems = _filterByDateRange(
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31),
        );
        break;
      case 'Custom Range':
        if (_selectedDateRange != null) {
          filteredItems = _filterByDateRange(
            _selectedDateRange!.start,
            _selectedDateRange!.end,
          );
        } else {
          filteredItems = [];
        }
        break;
      default:
        filteredItems = widget.profitItems;
    }

    if (filteredItems.isEmpty) {
      return const Center(child: Text("No data available for selected range."));
    }

    Map<String, List<Map<String, dynamic>>> groupedItems = {};
    for (var item in filteredItems) {
      DateTime itemDate = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
      String dateKey = DateFormat('yyyy-MM-dd').format(itemDate);

      if (!groupedItems.containsKey(dateKey)) {
        groupedItems[dateKey] = [];
      }
      groupedItems[dateKey]!.add(item);
    }

    var sortedDates = groupedItems.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        String date = sortedDates[index];
        var dateItems = groupedItems[date]!;
        DateTime dateTime = DateTime.parse(date);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              child: Text(
                DateFormat('MMMM d, yyyy').format(dateTime),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...dateItems.map((item) => _buildProfitItem(item)).toList(),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _filterByDateRange(DateTime startDate, DateTime endDate) {
    return widget.profitItems.where((item) {
      try {
        DateTime itemDate = DateTime.tryParse(item['date'] ?? '') ?? DateTime.now();
        return itemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            itemDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  Widget _buildProfitItem(Map<String, dynamic> item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(item['name']?.toString() ?? 'Unknown Item'),
        subtitle: Text(
          "Qty: ${item['quantity']?.toString() ?? '0'} | "
              "Revenue: \$${(item['revenue'] ?? 0).toStringAsFixed(2)} | "
              "Cost: \$${(item['cost'] ?? 0).toStringAsFixed(2)}",
        ),
        trailing: Text(
          "Profit: \$${(item['profit'] ?? 0).toStringAsFixed(2)}",
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}