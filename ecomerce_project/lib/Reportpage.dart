import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'Revenuedetailpage.dart';
import 'orderdetailspage.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");

  int totalOrders = 0;
  double totalRevenue = 0;
  List<Map<String, dynamic>> orderList = [];

  @override
  void initState() {
    super.initState();
    _calculateReport();
  }

  void _calculateReport() async {
    final snapshot = await ordersRef.get();

    double revenue = 0;
    int orders = 0;
    List<Map<String, dynamic>> fetchedOrders = [];

    if (snapshot.exists) {
      final data = snapshot.value as Map;

      data.forEach((orderId, orderData) {
        if (orderData is Map) {
          final price = double.tryParse(orderData['price'].toString()) ?? 0;
          final quantity = int.tryParse(orderData['quantity'].toString()) ?? 1;
          final name = orderData['name'] ?? 'Unknown';
          final date = orderData['date'] ?? '';
          revenue += price * quantity;
          orders++;
          fetchedOrders.add({
            'name': name,
            'price': price,
            'quantity': quantity,
            'date': date,
          });

        }
      });
    } else {
      print(" No orders found in Firebase.");
    }

    setState(() {
      totalRevenue = revenue;
      totalOrders = orders;
      orderList = fetchedOrders;
    });

    print(" Total Orders: $orders");
    print(" Total Revenue: $revenue");
    print(" Orders fetched: ${orderList.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.indigo,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildReportCard("Total Orders", totalOrders.toString(), Colors.orange),
            const SizedBox(height: 50),
            _buildReportCard("Total Revenue", "\$${totalRevenue.toStringAsFixed(2)}", Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(String title, String value, Color color) {
    return InkWell(
      onTap: () {
        if (title == "Total Orders") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderDetailsPage(orderList: orderList),
            ),
          );
        } else if (title == "Total Revenue") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RevenueDetailsPage(orderList: orderList),
            ),
          );
        }
      },
      child: SizedBox(
        height: 70,
        child: Card(
          elevation: 4,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(Icons.bar_chart, color: color),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text(value, style: const TextStyle(fontSize: 18, color: Colors.black)),
          ),
        ),
      ),
    );
  }

}