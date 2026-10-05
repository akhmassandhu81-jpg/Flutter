import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ViewOrder extends StatefulWidget {
  const ViewOrder({super.key});

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Customer Orders"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder(
        stream: ordersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final data = Map<String, dynamic>.from(
              snapshot.data!.snapshot.value as Map,
            );

            final orders = data.entries.map((e) {
              final value = Map<String, dynamic>.from(e.value);
              value['key'] = e.key;
              return value;
            }).toList();

            final pending = orders.where((o) => o['status'] == null || o['status'] == 'pending').toList();
            final accepted = orders.where((o) => o['status'] == 'accepted').toList();
            final rejected = orders.where((o) => o['status'] == 'rejected').toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text("Payment received  Order pending ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...pending.map((order) => pendingOrderCard(order)),

                  const SizedBox(height: 30),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(" Accepted Orders",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            ...accepted.map((order) => statusCard(order, Colors.green)),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(" Rejected Orders",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            ...rejected.map((order) => statusCard(order, Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text("No orders found", style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        },
      ),
    );
  }

  Widget pendingOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  "${order['qty'] ?? '?'}x",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(order['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Price: \$${order['price'] ?? 0}"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    ordersRef.child(order['key']).update({'status': 'accepted'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Accept"),
                ),
                ElevatedButton(
                  onPressed: () {
                    ordersRef.child(order['key']).update({'status': 'rejected'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text("Reject"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget statusCard(Map<String, dynamic> order, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            "${order['qty'] ?? '?'}x",
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(order['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Price: \$${order['price']??0}"),
      ),
    );
  }
}