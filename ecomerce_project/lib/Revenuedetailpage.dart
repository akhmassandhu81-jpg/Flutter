import 'package:ecomerce_project/profit_details.dart';
import 'package:flutter/material.dart';

import 'Review Reveneue.dart';
import 'loss_details.dart';

class RevenueDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderList;

  const RevenueDetailsPage({super.key, required this.orderList});

  double getCostPrice(String name) {
    Map<String, double> costPrices = {
      'Product A': 5.0,
      'Product B': 8.0,
      'Product C': 10.0,
      'Product D': 12.0,
      'Soap': 15.0,
      'Shampoo': 20.0,
      'Toothpaste': 10.0,
      'Tissue Box': 7.0,
      'Water Bottle': 8.0,
      'Biscuits': 5.0,
      'Juice': 12.0,
      'Chips': 6.0,
    };


    return costPrices[name] ?? 8.0;
  }

  @override
  Widget build(BuildContext context) {
    double totalRevenue = 0;
    double totalCost = 0;
    double totalProfit = 0;
    double totalLoss = 0;

    List<Map<String, dynamic>> profitItems = [];
    List<Map<String, dynamic>> lossItems = [];

    for (var order in orderList) {
      final name = order['name'] ?? 'Unknown';
      final sellingPrice = order['price'] ?? 0;
      final quantity = order['quantity'] ?? 1;

      final costPrice = getCostPrice(name);
      final revenue = sellingPrice * quantity;
      final cost = costPrice * quantity;
      final difference = revenue - cost;

      totalRevenue += revenue;
      totalCost += cost;

      if (difference >= 0) {
        totalProfit += difference;
        profitItems.add({
          'name': name,
          'quantity': quantity,
          'revenue': revenue,
          'cost': cost,
          'profit': difference,
        });
      } else {
        totalLoss += difference.abs();
        lossItems.add({
          'name': name,
          'quantity': quantity,
          'revenue': revenue,
          'cost': cost,
          'loss': difference.abs(),
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Revenue Details"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
           onTap: (){
             Navigator.push(context, MaterialPageRoute(builder: (context)=>RevenueBreakdownPage(orderList: orderList,)));
           },   
              
              child: _buildSummaryCard("Total Revenue", totalRevenue, Colors.blue)),
          SizedBox(height: 50,),
          _buildSummaryCard("Total Cost", totalCost, Colors.grey),
          SizedBox(height: 50,),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfitDetailsPage(profitItems: profitItems,)));
            },
              child: _buildSummaryCard("Total Profit", totalProfit, Colors.green)),
          SizedBox(height: 50,),
          GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LossDetailsPage(lossItems: lossItems,)));
              },
              child: _buildSummaryCard("Total Loss", totalLoss, Colors.red)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildSummaryCard(String title, double value, Color color) {
    return SizedBox(
      height: 70,
      child: Card(
        elevation: 3,
        child: ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Text(
            "\$${value.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 20, color: color),
          ),
        ),
      ),
    );
  }

  Widget _buildItemTile(Map<String, dynamic> item, {required bool isProfit}) {
    return Card(
      child: ListTile(
        title: Text(item['name']),
        subtitle: Text(
            "Qty: ${item['quantity']} | Revenue: \$${item['revenue'].toStringAsFixed(2)} | Cost: \$${item['cost'].toStringAsFixed(2)}"),
        trailing: Text(
          isProfit
              ? "Profit: \$${item['profit'].toStringAsFixed(2)}"
              : "Loss: \$${item['loss'].toStringAsFixed(2)}",
          style: TextStyle(
            color: isProfit ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
