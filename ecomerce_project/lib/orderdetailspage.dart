import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatelessWidget {
  final List<Map<String, dynamic>> orderList;

  const OrderDetailsPage({super.key, required this.orderList});

  String formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return "Unknown Date";
    }
  }

  Widget buildProductImage(String image) {
    try {
      if (image.startsWith("http")) {
        return Image.network(
          image,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 40),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        );
      } else {
        // handle base64
        final cleaned = image.contains(",") ? image.split(",")[1] : image;
        return Image.memory(
          base64Decode(cleaned),
          width: 70,
          height: 70,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return const Icon(Icons.error, size: 40);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: Colors.indigo,
      ),
      body: orderList.isEmpty
          ? const Center(child: Text("No orders to display"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderList.length,
        itemBuilder: (context, index) {
          final order = orderList[index];
          final imageStr = order['image'] ?? '';

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageStr.isNotEmpty
                    ? buildProductImage(imageStr)
                    : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
              title: Text(
                order['name'] ?? 'No Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Qty: ${order['quantity']}  |  Price: \$${order['price']}"),
                    const SizedBox(height: 4),
                    Text(formatDate(order['date'] ?? "")),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
