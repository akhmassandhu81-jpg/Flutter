import 'dart:convert';
import 'package:ecomerce_project/firstpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class cartpage extends StatefulWidget {
  const cartpage({super.key});

  @override
  State<cartpage> createState() => _cartpageState();
}

class _cartpageState extends State<cartpage> {
  final DatabaseReference cartRef = FirebaseDatabase.instance.ref("cart");
  final DatabaseReference productRef = FirebaseDatabase.instance.ref("products");

  List<Map<dynamic, dynamic>> cartItems = [];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  void fetchCartItems() {
    cartRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<Map<dynamic, dynamic>> tempList = [];
        data.forEach((key, value) {
          tempList.add({...value, 'key': key});
        });
        setState(() {
          cartItems = tempList;
        });
      } else {
        setState(() {
          cartItems = [];
        });
      }
    });
  }

  void deleteCartItem(String key) {
    cartRef.child(key).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item deleted")),
      );
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error deleting item")),
      );
    });
  }

  double getTotalPrice(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (sum, item) {
      final qty = item['qty'] ?? 1;
      final price = item['price'] ?? 0.0;
      return sum + (qty * price);
    });
  }

  ImageProvider getImageProvider(String imageString) {
    try {
      if (imageString.startsWith("http")) {
        return NetworkImage(imageString);
      } else {
        return MemoryImage(base64Decode(imageString));
      }
    } catch (e) {
      return const AssetImage("assets/placeholder.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> groupedItems = {};
    for (var item in cartItems) {
      String key = item['name'] ?? 'Unknown Item';

      int qty = 1;
      if (item['qty'] != null) {
        try {
          qty = int.parse(item['qty'].toString());
        } catch (e) {
          qty = 1;
        }
      }

      double price = 0;
      if (item['price'] != null) {
        try {
          price = double.parse(item['price'].toString());
        } catch (e) {
          price = 0;
        }
      }

      if (groupedItems.containsKey(key)) {
        groupedItems[key]!['qty'] += qty;
      } else {
        groupedItems[key] = {
          'name': key,
          'qty': qty,
          'price': price,
          'image': item['image'] ?? '',
          'key': item['key'],
        };
      }
    }

    List<Map<String, dynamic>> finalCart = groupedItems.values.toList();
    double total = getTotalPrice(finalCart);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isWideScreen = screenWidth > 600;

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
        title: const Center(
            child: Text(
              "Cart",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            )),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.shopping_cart,color: Colors.white,size: 30,),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: finalCart.isEmpty
            ? const Center(child: Text("Cart is empty"))
            : Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: finalCart.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = finalCart[index];

                  return FutureBuilder(
                    future: productRef
                        .orderByChild("name")
                        .equalTo(item['name'])
                        .once(),
                    builder: (context, snapshot) {
                      int availableStock = 0;
                      if (snapshot.hasData &&
                          (snapshot.data as DatabaseEvent)
                              .snapshot
                              .value !=
                              null) {
                        final productMap = Map<String, dynamic>.from(
                            ((snapshot.data as DatabaseEvent)
                                .snapshot
                                .value as Map)
                                .values
                                .first);
                        availableStock = int.tryParse(
                            productMap['quantity'].toString()) ??
                            0;
                      }

                      final bool inStock =
                          item['qty'] <= availableStock;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        leading: Container(
                          width: isWideScreen ? 120 : 80,
                          height: isWideScreen ? 120 : 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: getImageProvider(item['image'] ?? ''),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        title: Text(
                          item['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Price: \$${item['price'].toStringAsFixed(2)}"),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    int currentQty = item['qty'];
                                    if (currentQty > 1) {
                                      cartRef
                                          .child(item['key'])
                                          .update({'qty': currentQty - 1});
                                    } else {
                                      deleteCartItem(item['key']);
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                  color: Colors.red,
                                ),
                                Text(
                                  '${item['qty']}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: () {
                                    int currentQty = item['qty'];
                                    cartRef.child(item['key']).update(
                                        {'qty': currentQty + 1});
                                  },
                                  icon: const Icon(Icons.add),
                                  color: Colors.green,
                                ),
                              ],
                            ),
                            if (!inStock)
                              const Text(
                                "Not enough stock!",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              )
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red),
                          onPressed: () {
                            deleteCartItem(item['key']);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Add all",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  "Total: \$${total.toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.indigo),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: isWideScreen ? 400 : double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    bool allInStock = true;
                    for (var item in finalCart) {
                      productRef
                          .orderByChild("name")
                          .equalTo(item['name'])
                          .once()
                          .then((event) {
                        final data = event.snapshot.value as Map?;
                        if (data != null) {
                          final productMap =
                          Map<String, dynamic>.from(
                              data.values.first);
                          int available = int.tryParse(
                              productMap['quantity'].toString()) ??
                              0;
                          if (item['qty'] > available) {
                            allInStock = false;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Only $available in stock for ${item['name']}. Reduce quantity."),
                              ),
                            );
                          } else {
                            // proceed
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    firstpage(cartItems: finalCart),
                              ),
                            );
                          }
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Place Order"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}