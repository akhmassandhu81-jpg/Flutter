import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:ecomerce_project/HomePage.dart';
import 'package:ecomerce_project/Searchpage.dart';
import 'package:ecomerce_project/cartpage.dart';
import 'package:ecomerce_project/mainscreen.dart';
import 'package:ecomerce_project/ratingpage.dart';
import 'package:flutter/material.dart';

import 'customer_order.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int myindex = 0;

  final List<Widget> myList = [
    mainscreen(),
    cartpage(),
    CustomerOrder(),
    Searchpage(),
  ];

  void onTapItem(int index) {
    setState(() {
      myindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myList[myindex],
      bottomNavigationBar: CurvedNavigationBar(
        index: myindex,
        height: 45.0,
        backgroundColor: Colors.transparent,
        color: Colors.indigo,
        buttonBackgroundColor: Colors.indigo,
        animationDuration: const Duration(milliseconds: 300),
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.shopping_cart, size: 30, color: Colors.white),
          Icon(Icons.receipt_long, size: 30, color: Colors.white),
          Icon(Icons.search, size: 30, color: Colors.white),
        ],
        onTap: onTapItem,
      ),
    );
  }
}
