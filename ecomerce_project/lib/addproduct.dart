import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final DatabaseReference productRef =
  FirebaseDatabase.instance.ref("products");

  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  String? _base64Image;

  Future<void> _imagepickfunc() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _image = pickedImage;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Product"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter Product Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            CustomTextField(
              controller: nameController,
              label: "Product Name",
              icon: Icons.shopping_bag,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: priceController,
              label: "Price",
              icon: Icons.attach_money,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: quantityController,
              label: "Quantity",
              icon: Icons.numbers,
              inputType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _imagepickfunc,
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick Image"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 10),
            _image != null
                ? kIsWeb
                ? Image.network(_image!.path, width: 200)
                : Image.file(File(_image!.path), width: 200)
                : const Text("No image selected."),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Product"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameController.text.trim();
                final price =
                    double.tryParse(priceController.text.trim()) ?? 0;
                final quantity =
                    double.tryParse(quantityController.text.trim()) ?? 0;
                final imageUrl = imageController.text.trim();

                final String? finalImage = _base64Image ?? imageUrl;

                if (name.isEmpty || finalImage == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please fill all fields correctly."),
                    backgroundColor: Colors.redAccent,
                  ));
                  return;
                }

                await productRef.push().set({
                  "name": name,
                  "price": price,
                  "image": finalImage,
                  "quantity": quantity,
                });

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Product added successfully!"),
                  backgroundColor: Colors.green,
                ));

                nameController.clear();
                priceController.clear();
                imageController.clear();
                quantityController.clear();

                setState(() {
                  _image = null;
                  _base64Image = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType inputType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.inputType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}