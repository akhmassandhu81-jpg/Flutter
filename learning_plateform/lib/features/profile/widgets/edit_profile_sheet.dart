import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/repositories/user_repository.dart';
import 'package:learning_plateform/models/user_model.dart';

class EditProfileSheet extends StatefulWidget {
  final UserModel user;

  const EditProfileSheet({super.key, required this.user});

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedClass;
  bool _isSaving = false;

  static const _classOptions = [
    MapEntry('class6', 'Class 6'),
    MapEntry('class7', 'Class 7'),
    MapEntry('class8', 'Class 8'),
    MapEntry('class9', 'Class 9'),
    MapEntry('class10', 'Class 10'),
    MapEntry('class11', 'Class 11'),
    MapEntry('class12', 'Class 12'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);

    final cl = widget.user.classLevel ?? 'class6';
    _selectedClass = _classOptions.any((e) => e.key == cl) ? cl : 'class6';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await UserRepository.instance.updateUser(
        widget.user.uid,
        {
          'fullName': _nameController.text.trim(),
          'classLevel': _selectedClass,
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update profile. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Edit Profile', style: AppTextStyles.heading1),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Full Name Field
                Text('Full Name', style: AppTextStyles.captionBold),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill,
                    hintText: 'Enter your name',
                    hintStyle: AppTextStyles.body2
                        .copyWith(color: AppColors.textTertiary),
                    prefixIcon: const Icon(Icons.person_outline_rounded,
                        color: AppColors.textSecondary, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.accentBlue),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your name'
                      : null,
                ),

                const SizedBox(height: 16),

                // Class Level Dropdown
                Text('Current Class', style: AppTextStyles.captionBold),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _selectedClass,
                  dropdownColor: AppColors.cardSurface,
                  style: AppTextStyles.body1,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill,
                    prefixIcon: const Icon(Icons.school_outlined,
                        color: AppColors.textSecondary, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  items: _classOptions.map((opt) {
                    return DropdownMenuItem<String>(
                      value: opt.key,
                      child: Text(opt.value, style: AppTextStyles.body1),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedClass = val);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // Read-only Email Field
                Text('Email Address', style: AppTextStyles.captionBold),
                const SizedBox(height: 6),
                TextFormField(
                  initialValue: widget.user.email,
                  enabled: false,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.textTertiary),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputFill.withValues(alpha: 0.5),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: AppColors.textMuted, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.borderSubtle),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('Email cannot be changed directly.',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textMuted, fontSize: 10)),

                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: AppColors.accentBlue,
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Save Changes', style: AppTextStyles.button),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
