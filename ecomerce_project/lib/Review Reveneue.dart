import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RevenueBreakdownPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderList;

  const RevenueBreakdownPage({super.key, required this.orderList});

  @override
  Widget build(BuildContext context) {
    final dateRange = _getDateRange();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Revenue Breakdown"),
          backgroundColor: Colors.indigo,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "Annual"),
              Tab(text: "Monthly"),
              Tab(text: "Daily"),
            ],
          ),
        ),
        body: Column(
          children: [
            if (dateRange != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.date_range, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      "From: ${DateFormat.yMMMd().format(dateRange['start']!)}  →  To: ${DateFormat.yMMMd().format(dateRange['end']!)}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAnnualTab(),
                  _buildMonthlyTab(),
                  _buildDailyTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Map<String, DateTime>? _getDateRange() {
    List<DateTime> dates = [];

    for (var order in orderList) {
      final dateStr = order['date'];
      if (dateStr != null) {
        try {
          final parsed = DateTime.parse(dateStr);
          dates.add(parsed);
        } catch (_) {}
      }
    }

    if (dates.isEmpty) return null;

    dates.sort();
    return {'start': dates.first, 'end': dates.last};
  }


  Widget _buildAnnualTab() {
    Map<int, double> revenueByYear = {
      2022: 12000.0,
      2023: 15000.0,
    };

    for (var order in orderList) {
      final dateStr = order['date'];
      final price = order['price'] ?? 0.0;
      final qty = order['quantity'] ?? 1;
      final revenue = price * qty;

      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          revenueByYear[date.year] = (revenueByYear[date.year] ?? 0) + revenue;
        } catch (_) {}
      }
    }

    final sortedYears = revenueByYear.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: sortedYears.map((year) {
        return _buildRevenueTile("Year $year", revenueByYear[year]!);
      }).toList(),
    );
  }


  Widget _buildMonthlyTab() {
    final now = DateTime.now();
    double total = 0;

    for (var order in orderList) {
      final dateStr = order['date'];
      final price = order['price'] ?? 0.0;
      final qty = order['quantity'] ?? 1;
      final revenue = price * qty;

      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          if (date.year == now.year && date.month == now.month) {
            total += revenue;
          }
        } catch (_) {}
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildRevenueTile("Month: ${DateFormat.yMMMM().format(now)}", total),
    );
  }

  // === DAILY TAB ===
  Widget _buildDailyTab() {
    final now = DateTime.now();
    double total = 0;

    for (var order in orderList) {
      final dateStr = order['date'];
      final price = order['price'] ?? 0.0;
      final qty = order['quantity'] ?? 1;
      final revenue = price * qty;

      if (dateStr != null) {
        try {
          final date = DateTime.parse(dateStr);
          if (date.year == now.year &&
              date.month == now.month &&
              date.day == now.day) {
            total += revenue;
          }
        } catch (_) {}
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: _buildRevenueTile("Today: ${DateFormat.yMMMMd().format(now)}", total),
    );
  }

  Widget _buildRevenueTile(String title, double value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          "\$${value.toStringAsFixed(2)}",
          style: const TextStyle(fontSize: 16, color: Colors.blue),
        ),
      ),
    );
  }
}
