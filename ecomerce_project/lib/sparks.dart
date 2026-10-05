import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class sparks extends StatefulWidget {
  final String title;
  final double price;
  final String image;

  const sparks({
    super.key,
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  State<sparks> createState() => _sparksState();
}

class _sparksState extends State<sparks> {
  Widget buildProductImage(String image) {
    try {
      if (image.startsWith("http")) {
        return Image.network(
          image,
          width: double.infinity,
          height: 230,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 100),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
        );
      } else {
        return Image.memory(
          base64Decode(image),
          width: double.infinity,
          height: 230,
          fit: BoxFit.cover,
        );
      }
    } catch (e) {
      return const Icon(Icons.error, size: 100);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Product Details",
            style: TextStyle(
                color: Colors.indigo, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.indigo),

      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: buildProductImage(widget.image),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "\$${widget.price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                final cartRef = FirebaseDatabase.instance.ref("cart");
                cartRef.push().set({
                  'name': widget.title,
                  'price': widget.price,
                  'image': widget.image,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Product added to cart successfully")),
                );
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text("Add to Cart"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Product Description",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Explore more about ${widget.title}. This is one of our best-selling products at an unbeatable price.",
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
