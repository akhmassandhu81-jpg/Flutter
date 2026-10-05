import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/services/backup_restore_service.dart';
import '../../repositories/shop_repository.dart';
import '../../models/shop_settings_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ShopRepository _repository = ShopRepository();
  final BackupRestoreService _backupService = BackupRestoreService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _taxNumberController;
  late TextEditingController _currencySymbolController;
  late TextEditingController _defaultTaxRateController;
  late TextEditingController _minStockController;
  late TextEditingController _footerNoteController;

  bool _isInitialized = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  void _initControllers(ShopSettings settings) {
    if (_isInitialized) return;
    _shopNameController = TextEditingController(text: settings.shopName);
    _addressController = TextEditingController(text: settings.address);
    _phoneController = TextEditingController(text: settings.phone);
    _emailController = TextEditingController(text: settings.email);
    _taxNumberController = TextEditingController(text: settings.taxNumber);
    _currencySymbolController = TextEditingController(text: settings.currencySymbol);
    _defaultTaxRateController = TextEditingController(text: settings.defaultTaxRate.toString());
    _minStockController = TextEditingController(text: settings.defaultMinStockLevel.toString());
    _footerNoteController = TextEditingController(text: settings.receiptFooterNote);
    _isInitialized = true;
  }

  Future<void> _handleBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final timestamp = DateFormat('yyyy-MM-dd_HHmm').format(DateTime.now());
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Database Backup',
        fileName: 'ShopBilling_Backup_$timestamp.sbbak',
        allowedExtensions: ['sbbak', 'db'],
        type: FileType.custom,
      );

      if (outputPath != null) {
        await _backupService.createManualBackup(outputPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Backup created successfully at: $outputPath'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _handleRestore() async {
    // Show warning confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Database Warning'),
        content: const Text(
          'Restoring a backup will completely replace your current local database with the selected backup file.\n\n'
          'An automatic safety backup of your current database will be created before restoration.\n\n'
          'Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Proceed & Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isRestoring = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Database Backup to Restore',
        type: FileType.custom,
        allowedExtensions: ['sbbak', 'db'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        await _backupService.restoreDatabase(filePath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database restored successfully! Restart app if needed.'), backgroundColor: AppColors.success),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopSettings>(
      stream: _repository.shopSettingsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingWidget(message: 'Loading Shop Settings...');
        }

        final settings = snapshot.data!;
        _initControllers(settings);

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Shop Configuration & Settings',
                subtitle: 'Customize shop details, invoice receipts, default tax, currency, and database backup/restore',
              ),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Business Profile Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _shopNameController,
                                decoration: const InputDecoration(labelText: 'Shop / Store Name *', prefixIcon: Icon(Icons.store)),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Shop name is required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _taxNumberController,
                                decoration: const InputDecoration(labelText: 'Tax Registration # / STRN', prefixIcon: Icon(Icons.receipt)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _phoneController,
                                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Store Address', prefixIcon: Icon(Icons.location_on)),
                          maxLines: 2,
                        ),

                        const Divider(height: 32),
                        const Text('POS & Invoice Defaults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _currencySymbolController,
                                decoration: const InputDecoration(labelText: 'Currency Symbol *', prefixIcon: Icon(Icons.attach_money)),
                                validator: (val) => (val == null || val.trim().isEmpty) ? 'Currency symbol is required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _defaultTaxRateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Default Tax Rate (%)', prefixIcon: Icon(Icons.percent)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _minStockController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Default Low Stock Level', prefixIcon: Icon(Icons.warning_amber)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _footerNoteController,
                          decoration: const InputDecoration(labelText: 'Receipt Footer Notice', prefixIcon: Icon(Icons.note)),
                          maxLines: 3,
                        ),

                        const SizedBox(height: 24),

                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final updated = ShopSettings(
                                shopName: _shopNameController.text.trim(),
                                address: _addressController.text.trim(),
                                phone: _phoneController.text.trim(),
                                email: _emailController.text.trim(),
                                taxNumber: _taxNumberController.text.trim(),
                                currencySymbol: _currencySymbolController.text.trim(),
                                defaultTaxRate: double.tryParse(_defaultTaxRateController.text.trim()) ?? 0.0,
                                defaultMinStockLevel: int.tryParse(_minStockController.text.trim()) ?? 5,
                                receiptFooterNote: _footerNoteController.text.trim(),
                              );

                              await _repository.updateShopSettings(updated);

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Shop settings updated successfully!'), backgroundColor: AppColors.success),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Configuration'),
                        ),

                        const Divider(height: 48),
                        const Text('Database Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        const Text('Protect your business data by creating secure backups or restoring from a previous backup file.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                              onPressed: _isBackingUp ? null : _handleBackup,
                              icon: _isBackingUp ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.backup),
                              label: Text(_isBackingUp ? 'Creating Backup...' : 'Create Backup (.sbbak)'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
                              onPressed: _isRestoring ? null : _handleRestore,
                              icon: _isRestoring ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.restore),
                              label: Text(_isRestoring ? 'Restoring Database...' : 'Restore Database'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
