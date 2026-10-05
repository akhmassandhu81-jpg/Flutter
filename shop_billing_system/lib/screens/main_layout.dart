import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/widgets/app_states.dart';
import '../providers/connectivity_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/auth_provider.dart';
import '../repositories/shop_repository.dart';
import '../models/product_model.dart';
import 'dashboard/dashboard_screen.dart';
import 'pos/pos_screen.dart';
import 'products/products_screen.dart';
import 'categories/categories_screen.dart';
import 'inventory/inventory_screen.dart';
import 'purchases/purchases_screen.dart';
import 'suppliers/suppliers_screen.dart';
import 'customers/customers_screen.dart';
import 'sales/sales_screen.dart';
import 'expenses/expenses_screen.dart';
import 'reports/reports_screen.dart';
import 'audit/audit_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  final ValueChanged<bool> onToggleTheme;
  final bool isDarkMode;

  const MainLayout({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  final ShopRepository _repository = ShopRepository();

  final List<NavigationDestinationItem> _navigationItems = const [
    NavigationDestinationItem(index: 0, label: 'Dashboard', icon: Icons.dashboard_outlined, selectedIcon: Icons.dashboard),
    NavigationDestinationItem(index: 1, label: 'POS / New Sale', icon: Icons.point_of_sale_outlined, selectedIcon: Icons.point_of_sale),
    NavigationDestinationItem(index: 2, label: 'Products', icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2),
    NavigationDestinationItem(index: 3, label: 'Categories', icon: Icons.category_outlined, selectedIcon: Icons.category),
    NavigationDestinationItem(index: 4, label: 'Inventory', icon: Icons.warehouse_outlined, selectedIcon: Icons.warehouse),
    NavigationDestinationItem(index: 5, label: 'Purchases', icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag),
    NavigationDestinationItem(index: 6, label: 'Suppliers', icon: Icons.local_shipping_outlined, selectedIcon: Icons.local_shipping),
    NavigationDestinationItem(index: 7, label: 'Customers', icon: Icons.people_outline, selectedIcon: Icons.people),
    NavigationDestinationItem(index: 8, label: 'Sales & Invoices', icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long),
    NavigationDestinationItem(index: 9, label: 'Expenses', icon: Icons.payments_outlined, selectedIcon: Icons.payments),
    NavigationDestinationItem(index: 10, label: 'Reports', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart),
    NavigationDestinationItem(index: 11, label: 'Audit Logs', icon: Icons.assignment_outlined, selectedIcon: Icons.assignment),
    NavigationDestinationItem(index: 12, label: 'Settings', icon: Icons.settings_outlined, selectedIcon: Icons.settings),
  ];

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return DashboardScreen(onNavigate: _navigateTo);
      case 1:
        return const PosScreen();
      case 2:
        return const ProductsScreen();
      case 3:
        return const CategoriesScreen();
      case 4:
        return const InventoryScreen();
      case 5:
        return const PurchasesScreen();
      case 6:
        return const SuppliersScreen();
      case 7:
        return const CustomersScreen();
      case 8:
        return const SalesScreen();
      case 9:
        return const ExpensesScreen();
      case 10:
        return const ReportsScreen();
      case 11:
        return const AuditScreen();
      case 12:
        return const SettingsScreen();
      default:
        return DashboardScreen(onNavigate: _navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final isOnline = connectivityAsync.value ?? true;
    final pendingCount = ref.watch(syncStatusProvider);
    final userSession = ref.watch(userSessionProvider);

    // If connectivity returns true, trigger sync engine
    ref.listen(connectivityStreamProvider, (prev, next) {
      if (next.value == true) {
        ref.read(syncStatusProvider.notifier).triggerSync();
      }
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth >= 900;

        return Scaffold(
          appBar: AppBar(
            leading: isDesktop
                ? IconButton(
                    icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open),
                    onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                    tooltip: 'Toggle Sidebar',
                  )
                : Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
            title: Row(
              children: [
                const Icon(Icons.storefront, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${userSession.businessName.toUpperCase()} - POS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            actions: [
              // Sync Status Indicator
              SyncStatusIndicator(
                isOnline: isOnline,
                pendingCount: pendingCount,
                onSyncTap: () => ref.read(syncStatusProvider.notifier).triggerSync(),
              ),

              const SizedBox(width: 8),

              // Low Stock Quick Warning Stream
              StreamBuilder<List<Product>>(
                stream: _repository.productsStream,
                builder: (context, snapshot) {
                  final lowStockCount = snapshot.data?.where((p) => p.isLowStock || p.isOutOfStock).length ?? 0;
                  if (lowStockCount == 0) return const SizedBox.shrink();

                  return Tooltip(
                    message: '$lowStockCount products low/out of stock',
                    child: InkWell(
                      onTap: () => _navigateTo(4),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$lowStockCount Alert',
                              style: const TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // POS Quick Button
              if (_selectedIndex != 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _navigateTo(1),
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('POS Sale', style: TextStyle(fontSize: 13)),
                  ),
                ),

              // Theme Toggle
              IconButton(
                icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => widget.onToggleTheme(!widget.isDarkMode),
                tooltip: widget.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
              ),

              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(userSession.name[0], style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
            ],
          ),
          drawer: !isDesktop
              ? Drawer(
                  child: _buildSidebarContent(isDark, isMobileDrawer: true),
                )
              : null,
          body: Column(
            children: [
              OfflineBanner(isOffline: !isOnline),
              Expanded(
                child: Row(
                  children: [
                    if (isDesktop)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _isSidebarCollapsed ? 70 : 240,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          border: Border(
                            right: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                        ),
                        child: _buildSidebarContent(isDark, isMobileDrawer: false),
                      ),
                    Expanded(
                      child: Container(
                        color: isDark ? AppColors.bgDark : AppColors.bgLight,
                        padding: const EdgeInsets.all(20),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            key: ValueKey<int>(_selectedIndex),
                            child: _buildScreen(_selectedIndex),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSidebarContent(bool isDark, {required bool isMobileDrawer}) {
    bool collapsed = _isSidebarCollapsed && !isMobileDrawer;

    return Column(
      children: [
        if (isMobileDrawer) ...[
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: const Text('Shop Admin', style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text('admin@shop.com'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, color: AppColors.primary, size: 32),
            ),
          ),
        ],
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: _navigationItems.length,
            itemBuilder: (context, index) {
              final item = _navigationItems[index];
              final isSelected = _selectedIndex == item.index;

              if (collapsed) {
                return Tooltip(
                  message: item.label,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: IconButton(
                      icon: Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      onPressed: () {
                        _navigateTo(item.index);
                        if (isMobileDrawer) Navigator.pop(context);
                      },
                    ),
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  dense: true,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  selected: isSelected,
                  selectedTileColor: isDark ? AppColors.primary.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                  leading: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    size: 20,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primary : (isDark ? Colors.grey[300] : Colors.grey[800]),
                    ),
                  ),
                  onTap: () {
                    _navigateTo(item.index);
                    if (isMobileDrawer) Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class NavigationDestinationItem {
  final int index;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationItem({
    required this.index,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
