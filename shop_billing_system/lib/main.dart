import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/services/sqlite_database_service.dart';
import 'screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SQLite database service
  await SqliteDatabaseService().database;

  runApp(
    const ProviderScope(
      child: ShopBillingApp(),
    ),
  );
}

class ShopBillingApp extends StatefulWidget {
  const ShopBillingApp({super.key});

  @override
  State<ShopBillingApp> createState() => _ShopBillingAppState();
}

class _ShopBillingAppState extends State<ShopBillingApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Inventory & POS System (Offline-First)',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MainLayout(
        onToggleTheme: _toggleTheme,
        isDarkMode: _isDarkMode,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
