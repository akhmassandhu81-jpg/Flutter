import 'package:ecomerce_project/HomePage.dart';
import 'package:ecomerce_project/HomeScreen.dart';
import 'package:ecomerce_project/Searchpage.dart';
import 'package:ecomerce_project/admindashboard.dart';
import 'package:ecomerce_project/cartpage.dart';
import 'package:ecomerce_project/firstpage.dart';
import 'package:ecomerce_project/loginScreen.dart';
import 'package:ecomerce_project/mainscreen.dart';
import 'package:ecomerce_project/ratingpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env["STRIPE_PUBLISH_KEY"]!;
  await Stripe.instance.applySettings();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
