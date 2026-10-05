import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class CustomerOrder extends StatefulWidget {
  const CustomerOrder({super.key});

  @override
  State<CustomerOrder> createState() => _CustomerOrderState();
}

class _CustomerOrderState extends State<CustomerOrder> {
  final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3E8EFB), Color(0xFF004AAD)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text("Your Orders",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 22),),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ordersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text("No orders found."));
          }

          final data = snapshot.data!.snapshot.value;
          Map<String, dynamic> ordersMap = {};

          try {
            if (data is Map) {
              ordersMap = Map<String, dynamic>.from(data);
            } else if (data is List) {
              ordersMap = {
                for (var i = 0; i < data.length; i++)
                  if (data[i] != null) i.toString(): data[i]
              };
            } else {
              return const Center(child: Text("Unexpected data format."));
            }

            final orders = ordersMap.entries.map((entry) {
              final order = Map<String, dynamic>.from(entry.value as Map);
              order['key'] = entry.key;
              return order;
            }).toList();

            if (orders.isEmpty) {
              return const Center(child: Text("No orders yet."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final status = order['status'] ?? 'pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            status == 'accepted' ? Colors.green : Colors.orange,
                            child: Text(
                              "${order['qty'] ?? '?'}x",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            order['name']?.toString() ?? 'No name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("Price: \$${order['price']?.toString() ?? '0'}"),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          status == 'accepted'
                              ? " Your order has been accepted and is On the way."
                              : " Your order is pending. Please wait for confirmation.",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } catch (e) {
            return Center(child: Text("Error processing data: $e"));
          }
        },
      ),
    );
  }
}
