import 'package:flutter/material.dart';

class LossDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> lossItems;

  const LossDetailsPage({super.key, required this.lossItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loss Details"),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lossItems.length,
        itemBuilder: (context, index) {
          final item = lossItems[index];
          return Card(
            elevation: 3,
            child: ListTile(
              title: Text(item['name']),
              subtitle: Text(
                "Qty: ${item['quantity']} | Revenue: \$${item['revenue'].toStringAsFixed(2)} | Cost: \$${item['cost'].toStringAsFixed(2)}",
              ),
              trailing: Text(
                "Loss: \$${item['loss'].toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
