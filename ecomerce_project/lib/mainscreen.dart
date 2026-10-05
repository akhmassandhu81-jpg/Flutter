import 'dart:convert';
import 'package:ecomerce_project/admindashboard.dart';
import 'package:ecomerce_project/sparks.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class mainscreen extends StatefulWidget {
  const mainscreen({super.key});

  @override
  State<mainscreen> createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {
  final DatabaseReference _productRef =
  FirebaseDatabase.instance.ref("products");
  List<Map<dynamic, dynamic>> _products = [];
  double? _enteredMinPrice;
  double? _enteredMaxPrice;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool _showPriceFilter = false;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    _productRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        final List<Map<dynamic, dynamic>> loaded = [];
        data.forEach((key, value) {
          loaded.add(value as Map);
        });
        setState(() {
          _products = loaded;
        });
      }
    });
  }

  Widget buildProductCard(Map product) {
    final String name = product['name'] ?? 'Unknown';
    final dynamic price = product['price'] ?? 0;
    final String? image = product['image'];

    Widget productImage;
    try {
      if (image != null && image.startsWith("http")) {
        productImage = Image.network(
          image,
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else if (image != null) {
        productImage = Image.memory(
          base64Decode(image),
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } else {
        productImage = Container(
          height: 160,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported, size: 40),
        );
      }
    } catch (e) {
      productImage = Container(
        height: 160,
        color: Colors.grey[200],
        child: const Icon(Icons.error, size: 40),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => sparks(
              title: name,
              price: double.tryParse(price.toString()) ?? 0.0,
              image: image ?? '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.indigo.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: productImage,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                "\$${price.toString()}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    List<Map> filteredProducts = _products.where((product) {
      final price = double.tryParse(product['price'].toString()) ?? 0;
      final name = product['name'].toString().toLowerCase();
      final searchQuery = _searchController.text.toLowerCase();

      final withinPriceRange =
          (_enteredMinPrice == null || price >= _enteredMinPrice!) &&
              (_enteredMaxPrice == null || price <= _enteredMaxPrice!);
      final matchesSearch = name.contains(searchQuery);

      return withinPriceRange && matchesSearch;
    }).toList();

    filteredProducts.sort((a, b) =>
        (double.tryParse(a['price'].toString()) ?? 0)
            .compareTo(double.tryParse(b['price'].toString()) ?? 0));

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AdminDashboard()));
            },
            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://t4.ftcdn.net/jpg/04/75/00/99/360_F_475009987_zwsk4c77x3cTpcI3W1C1LU4pOSyPKaqi.jpg"),
              ),
            ),
          )
        ],
        title: const Text(
          "Online Shopping",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                hintText: "Search for products...",
                prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                suffixIcon:
                const Icon(Icons.camera_alt_rounded, color: Colors.indigo),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Price Filter Fields shown conditionally
            if (_showPriceFilter) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Min Price",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Max Price",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _enteredMinPrice =
                        double.tryParse(_minPriceController.text);
                    _enteredMaxPrice =
                        double.tryParse(_maxPriceController.text);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: const Text("Apply Filter"),
              ),
              const SizedBox(height: 10),
            ],

            // Title and filter icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Best Selling Products",
                  style: TextStyle(
                    color: Colors.indigo,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.filter_alt, color: Colors.indigo),
                  onPressed: () {
                    setState(() {
                      _showPriceFilter = !_showPriceFilter;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Product Grid
            Expanded(
              child: GridView.builder(
                itemCount: filteredProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return buildProductCard(filteredProducts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
