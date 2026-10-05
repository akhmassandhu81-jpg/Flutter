import 'package:ecomerce_project/payment.dart';
import 'package:ecomerce_project/textfields.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class firstpage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const firstpage({super.key, required this.cartItems});

  @override
  State<firstpage> createState() => _firstpageState();
}

class _firstpageState extends State<firstpage> {
  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();

  final formkey = GlobalKey<FormState>();
  final formkey1 = GlobalKey<FormState>();
  final formkey2 = GlobalKey<FormState>();
  final formkey3 = GlobalKey<FormState>();
  final formkey4 = GlobalKey<FormState>();
  final formkey5 = GlobalKey<FormState>();
  final formkey6 = GlobalKey<FormState>();

  List<String> currencyList = <String>['PKR', 'USD', 'INR', 'EUR', 'JPY', 'GBP', 'AED'];
  String selectedCurrency = 'PKR';

  Future<void> initPaymentSheet() async {
    try {
      final data = await cretaePaymentIntent(
        amount: (int.parse(amountController.text) * 100).toString(),
        currency: selectedCurrency,
        name: nameController.text,
        address: addressController.text,
        pin: pincodeController.text,
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Umair',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Page")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Make Your Payments Easily", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: ReusableTextField(
                      formkey: formkey,
                      controller: amountController,
                      isNumber: true,
                      title: "Total Order Amount",
                      hint: "Order Amount",
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownMenu<String>(
                    initialSelection: currencyList.first,
                    onSelected: (String? value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                    dropdownMenuEntries: currencyList.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
                  )
                ],
              ),
              SizedBox(height: 10),
              ReusableTextField(formkey: formkey1, title: "Name", hint: "Ex. Ali", controller: nameController),
              SizedBox(height: 10),
              ReusableTextField(formkey: formkey2, title: "Address", hint: "Ex. 123 Main St", controller: addressController),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: ReusableTextField(formkey: formkey3, title: "City", hint: "Ex. Lahore", controller: cityController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: ReusableTextField(formkey: formkey4, title: "State", hint: "Ex. LH", controller: stateController),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: ReusableTextField(formkey: formkey5, title: "Country", hint: "Ex. PK", controller: countryController),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: ReusableTextField(formkey: formkey6, title: "Pincode", hint: "123456", controller: pincodeController, isNumber: true),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent.shade400),
                  child: Text("Proceed to Pay", style: TextStyle(color: Colors.white, fontSize: 16)),
                  onPressed: () async {
                    if (formkey.currentState!.validate() &&
                        formkey1.currentState!.validate() &&
                        formkey2.currentState!.validate() &&
                        formkey3.currentState!.validate() &&
                        formkey4.currentState!.validate() &&
                        formkey5.currentState!.validate() &&
                        formkey6.currentState!.validate()) {
                      try {
                        await initPaymentSheet();
                        await Stripe.instance.presentPaymentSheet();

                        // Save payment details
                        final DatabaseReference paymentRef = FirebaseDatabase.instance.ref("payments");
                        await paymentRef.push().set({
                          'name': nameController.text.trim(),
                          'address': addressController.text.trim(),
                          'city': cityController.text.trim(),
                          'state': stateController.text.trim(),
                          'country': countryController.text.trim(),
                          'amount': amountController.text.trim(),
                          'currency': selectedCurrency,
                          'timestamp': DateTime.now().toIso8601String(),
                        });

                        // Save orders
                        final DatabaseReference ordersRef = FirebaseDatabase.instance.ref("orders");
                        for (var item in widget.cartItems) {
                          await ordersRef.push().set({
                            'name': item['name'],
                            'qty': item['qty'],
                            'price': item['price'],
                            'image': item['image'],
                            'status': 'pending',
                            'date': DateTime.now().toIso8601String(),
                          });
                        }

                        // Clear cart
                        final DatabaseReference cartRef = FirebaseDatabase.instance.ref("cart");
                        await cartRef.remove();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Order placed successfully!")),
                        );

                        Navigator.pop(context); // or navigate to home
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Payment failed: $e")),
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
