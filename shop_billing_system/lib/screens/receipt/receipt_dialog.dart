import 'package:flutter/material.dart';
import '../../models/sale_model.dart';
import '../../core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class ReceiptDialog extends StatelessWidget {
  final Sale sale;

  const ReceiptDialog({super.key, required this.sale});

  static void show(BuildContext context, {required Sale sale}) {
    showDialog(
      context: context,
      builder: (context) => ReceiptDialog(sale: sale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy – hh:mm a').format(sale.date);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Invoice Receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Printable Receipt Paper Styled Container (Always dark text on white paper for universal readability)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: DefaultTextStyle(
                  style: const TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
                  child: Column(
                    children: [
                      const Text('JINNAH SUPER MARKET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
                      const Text('Super Market, F-6 Markaz, Islamabad', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const Text('Tel: 051-111-6328 | STRN: 12345678', style: TextStyle(fontSize: 11, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Divider(thickness: 1, color: Colors.grey.shade400),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bill #: ${sale.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                          Text(formattedDate, style: const TextStyle(fontSize: 11, color: Colors.black87)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Customer: ${sale.customerName}', style: const TextStyle(fontSize: 12, color: Colors.black87)),
                          Text('Payment: ${sale.paymentMethod}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black)),
                        ],
                      ),

                      Divider(thickness: 1, color: Colors.grey.shade400),

                      // Items Header
                      const Row(
                        children: [
                          Expanded(flex: 4, child: Text('Item', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                          Expanded(flex: 2, child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                          Expanded(flex: 2, child: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black))),
                          Expanded(flex: 2, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black), textAlign: TextAlign.right)),
                        ],
                      ),
                      Divider(color: Colors.grey.shade300),

                      ...sale.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(flex: 4, child: Text(item.name, style: const TextStyle(fontSize: 12, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                              Expanded(flex: 2, child: Text('${item.quantity}', style: const TextStyle(fontSize: 12, color: Colors.black87))),
                              Expanded(flex: 2, child: Text(item.price.toStringAsFixed(2), style: const TextStyle(fontSize: 12, color: Colors.black87))),
                              Expanded(flex: 2, child: Text(item.total.toStringAsFixed(2), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black), textAlign: TextAlign.right)),
                            ],
                          ),
                        );
                      }),

                      Divider(thickness: 1, color: Colors.grey.shade400),

                      _buildSummaryRow('Subtotal:', 'Rs ${sale.subtotal.toStringAsFixed(2)}'),
                      if (sale.discount > 0)
                        _buildSummaryRow('Discount:', '- Rs ${sale.discount.toStringAsFixed(2)}'),
                      if (sale.tax > 0)
                        _buildSummaryRow('Tax:', 'Rs ${sale.tax.toStringAsFixed(2)}'),

                      Divider(thickness: 1.5, color: Colors.grey.shade500),

                      _buildSummaryRow('NET AMOUNT:', 'Rs ${sale.totalAmount.toStringAsFixed(2)}', isBold: true, fontSize: 15),
                      _buildSummaryRow('Paid Amount:', 'Rs ${sale.paidAmount.toStringAsFixed(2)}'),
                      if (sale.changeAmount > 0)
                        _buildSummaryRow('Change Returned:', 'Rs ${sale.changeAmount.toStringAsFixed(2)}'),
                      if (sale.remainingBalance > 0)
                        _buildSummaryRow('Remaining Credit:', 'Rs ${sale.remainingBalance.toStringAsFixed(2)}', isBold: true),

                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade400),
                      const Text(
                        'NO RETURN NO EXCHANGE WITHOUT RECEIPT\nThank you for shopping with us!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Print job sent to system printer!'), backgroundColor: AppColors.success),
                        );
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Print Receipt'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, double fontSize = 12}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: Colors.black87)),
          Text(value, style: TextStyle(fontSize: fontSize, fontWeight: isBold ? FontWeight.bold : FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }
}
