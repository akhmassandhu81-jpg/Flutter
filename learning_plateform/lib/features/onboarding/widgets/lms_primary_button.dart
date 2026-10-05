import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';

/// Full-width gradient primary button used across onboarding screens.
/// Matches the existing Login / SignUp button style.
class LMSPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;   // null → disabled
  final bool isLoading;
  final IconData? trailingIcon;

  const LMSPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: enabled
              ? AppColors.primaryGradient
              : const LinearGradient(
                  colors: [Color(0xFF2A3550), Color(0xFF2A3550)],
                ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.button.copyWith(
                      color: enabled ? Colors.white : AppColors.textTertiary,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 10),
                    Icon(
                      trailingIcon,
                      color: enabled ? Colors.white : AppColors.textTertiary,
                      size: 18,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
