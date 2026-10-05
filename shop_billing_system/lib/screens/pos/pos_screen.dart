import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/loading_widget.dart';
import '../../repositories/shop_repository.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/sale_model.dart';
import '../../models/customer_model.dart';
import '../receipt/receipt_dialog.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final ShopRepository _repository = ShopRepository();

  String _searchQuery = '';
  String _selectedCategoryId = 'All';

  // Cart State
  final List<CartItem> _cart = [];
  Customer? _selectedCustomer;
  String _paymentMethod = 'Cash';
  double _discountAmount = 0.0;
  final double _taxPercentage = 0.0;

  final TextEditingController _cashPaidController = TextEditingController();
  final TextEditingController _discountController = TextEditingController(text: '0');

  double get _subtotal => _cart.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get _taxAmount => (_subtotal - _discountAmount) * (_taxPercentage / 100);
  double get _grandTotal => (_subtotal - _discountAmount + _taxAmount).clamp(0.0, double.infinity);

  double get _cashPaid => double.tryParse(_cashPaidController.text) ?? _grandTotal;
  double get _changeAmount => (_cashPaid >= _grandTotal) ? (_cashPaid - _grandTotal) : 0.0;
  double get _remainingBalance => (_grandTotal > _cashPaid) ? (_grandTotal - _cashPaid) : 0.0;

  void _addToCart(Product product) {
    if (product.isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add "${product.name}" - Product is Out of Stock!'), backgroundColor: AppColors.danger),
      );
      return;
    }

    final existingIndex = _cart.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final currentQty = _cart[existingIndex].quantity;
      if (currentQty + 1 > product.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot exceed available stock of ${product.stock} ${product.unit}!'), backgroundColor: AppColors.warning),
        );
        return;
      }
      setState(() {
        _cart[existingIndex].quantity += 1;
      });
    } else {
      setState(() {
        _cart.add(CartItem(product: product, quantity: 1));
      });
    }
  }

  void _updateQuantity(int index, int delta, int maxStock) {
    final newQty = _cart[index].quantity + delta;
    if (newQty <= 0) {
      _removeFromCart(index);
    } else if (newQty > maxStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Max available stock is $maxStock'), backgroundColor: AppColors.warning),
      );
    } else {
      setState(() {
        _cart[index].quantity = newQty;
      });
    }
  }

  void _removeFromCart(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _discountAmount = 0.0;
      _discountController.text = '0';
      _cashPaidController.clear();
    });
  }

  Future<void> _completeSale(List<Product> availableProducts) async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add products before completing sale!'), backgroundColor: AppColors.warning),
      );
      return;
    }

    final now = DateTime.now();
    final invoiceNumber = 'INV-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final saleItems = _cart.map((item) {
      return SaleItem(
        productId: item.product.id,
        name: item.product.name,
        sku: item.product.sku,
        price: item.product.sellingPrice,
        purchasePrice: item.product.purchasePrice,
        quantity: item.quantity,
        total: item.totalPrice,
      );
    }).toList();

    final sale = Sale(
      id: '',
      invoiceNumber: invoiceNumber,
      date: now,
      customerId: _selectedCustomer?.id ?? '',
      customerName: _selectedCustomer?.name ?? 'Walk-in Customer',
      customerPhone: _selectedCustomer?.phone ?? '',
      items: saleItems,
      subtotal: _subtotal,
      discount: _discountAmount,
      tax: _taxAmount,
      totalAmount: _grandTotal,
      paidAmount: _cashPaid,
      changeAmount: _changeAmount,
      remainingBalance: _remainingBalance,
      paymentMethod: _paymentMethod,
      createdBy: 'Admin',
    );

    try {
      final saleId = await _repository.completeSale(
        sale: sale,
        currentProducts: availableProducts,
      );

      if (mounted) {
        ReceiptDialog.show(
          context,
          sale: sale.copyWith(id: saleId),
        );
      }

      _clearCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing sale: ${e.toString()}'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: _repository.categoriesStream,
      builder: (context, catSnap) {
        return StreamBuilder<List<Product>>(
          stream: _repository.productsStream,
          builder: (context, prodSnap) {
            return StreamBuilder<List<Customer>>(
              stream: _repository.customersStream,
              builder: (context, custSnap) {
                if (!catSnap.hasData || !prodSnap.hasData || !custSnap.hasData) {
                  return const LoadingWidget(message: 'Initializing POS Terminal...');
                }

                final categories = catSnap.data ?? [];
                final products = prodSnap.data ?? [];
                final customers = custSnap.data ?? [];

                final filteredProducts = products.where((p) {
                  if (!p.isActive) return false;
                  final query = _searchQuery.toLowerCase();
                  final matchesSearch = p.name.toLowerCase().contains(query) ||
                      p.sku.toLowerCase().contains(query) ||
                      p.barcode.toLowerCase().contains(query);
                  final matchesCategory = _selectedCategoryId == 'All' || p.categoryId == _selectedCategoryId;
                  return matchesSearch && matchesCategory;
                }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 950;

                    return isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Product Catalog Selection (60% width)
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: _buildProductCatalogSection(categories, filteredProducts),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Right: Cart & Checkout Panel (40% width)
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: constraints.maxHeight,
                                  child: _buildCartCheckoutSection(customers, products),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 600,
                                  child: _buildProductCatalogSection(categories, filteredProducts),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 700,
                                  child: _buildCartCheckoutSection(customers, products),
                                ),
                              ],
                            ),
                          );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductCatalogSection(List<Category> categories, List<Product> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'POS Terminal',
              subtitle: 'Select products to build customer invoice',
            ),

            // Search Bar
            TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search product by name, SKU, or scan barcode...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
            ),

            const SizedBox(height: 12),

            // Category Filter Chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ChoiceChip(
                    label: const Text('All Items'),
                    selected: _selectedCategoryId == 'All',
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategoryId = 'All');
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((c) {
                    final isSelected = _selectedCategoryId == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategoryId = selected ? c.id : 'All');
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Product Cards Grid (Expanded to fill available height & scroll)
            Expanded(
              child: products.isEmpty
                  ? const Center(child: Text('No active products found.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return Card(
                          elevation: 1,
                          color: p.isOutOfStock ? Colors.grey[100] : null,
                          child: InkWell(
                            onTap: () => _addToCart(p),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          p.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${p.sku.isNotEmpty ? p.sku : "N/A"}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Rs ${p.sellingPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                                      ),
                                      p.isOutOfStock
                                          ? StatusBadge.danger('Out')
                                          : Text('${p.stock} ${p.unit}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartCheckoutSection(List<Customer> customers, List<Product> availableProducts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (_cart.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearCart,
                    icon: const Icon(Icons.delete_sweep, size: 16, color: Colors.red),
                    label: const Text('Clear Cart', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Customer Selector Dropdown
            DropdownButtonFormField<Customer?>(
              value: _selectedCustomer,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'Customer',
                prefixIcon: Icon(Icons.person),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<Customer?>(
                  value: null,
                  child: Text('Walk-in Customer'),
                ),
                ...customers.map((c) {
                  return DropdownMenuItem<Customer?>(
                    value: c,
                    child: Text('${c.name} (${c.phone.isNotEmpty ? c.phone : "No Phone"})'),
                  );
                }),
              ],
              onChanged: (val) => setState(() => _selectedCustomer = val),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1),

            // Cart Items List (Expanded and scrollable)
            Expanded(
              child: _cart.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Cart is empty. Tap products to add.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: _cart.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text('Rs ${item.product.sellingPrice.toStringAsFixed(2)} / ${item.product.unit}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _updateQuantity(index, -1, item.product.stock),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 18),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _updateQuantity(index, 1, item.product.stock),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rs ${item.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _removeFromCart(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const Divider(height: 12),

            // Summary Totals & Checkout (Pinned at bottom)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal:', style: TextStyle(fontSize: 13)),
                    Text('Rs ${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),

                Row(
                  children: [
                    const Expanded(child: Text('Discount (Rs):', style: TextStyle(fontSize: 13))),
                    SizedBox(
                      width: 90,
                      child: TextField(
                        controller: _discountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.end,
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6)),
                        onChanged: (val) {
                          setState(() {
                            _discountAmount = double.tryParse(val) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Text('Payment: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        isDense: true,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                        items: const [
                          DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                          DropdownMenuItem(value: 'Card', child: Text('Card')),
                          DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                          DropdownMenuItem(value: 'On Account / Credit', child: Text('Customer Credit')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _paymentMethod = val);
                        },
                      ),
                    ),
                  ],
                ),

                if (_paymentMethod == 'Cash') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cashPaidController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount Paid (Rs)',
                      prefixIcon: Icon(Icons.payments, size: 18),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GRAND TOTAL:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            'Rs ${_grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                          ),
                        ],
                      ),
                      if (_paymentMethod == 'Cash' && _cashPaid > _grandTotal) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change Due:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('Rs ${_changeAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 12)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _completeSale(availableProducts),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Complete Sale & Print Receipt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.sellingPrice * quantity;
}
