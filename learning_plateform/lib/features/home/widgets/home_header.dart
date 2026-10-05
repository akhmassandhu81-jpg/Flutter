import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/models/user_model.dart';

/// Top header of the Home Screen.
/// Shows greeting, class/curriculum chip, notification bell, avatar.
class HomeHeader extends StatelessWidget {
  final UserModel user;

  const HomeHeader({super.key, required this.user});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _firstName {
    final parts = user.fullName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : user.fullName;
  }

  String get _initials {
    final parts = user.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.fullName.isNotEmpty
        ? user.fullName.substring(0, user.fullName.length.clamp(0, 2)).toUpperCase()
        : 'U';
  }

  String get _classChip {
    final cl = user.classLevel ?? '';
    final cu = user.curriculum ?? '';
    // Convert IDs to human-readable labels
    final classLabel      = _classLabel(cl);
    final curriculumLabel = _curriculumLabel(cu);
    if (classLabel.isEmpty && curriculumLabel.isEmpty) return '';
    if (classLabel.isNotEmpty && curriculumLabel.isNotEmpty) {
      return '$classLabel • $curriculumLabel';
    }
    return classLabel.isNotEmpty ? classLabel : curriculumLabel;
  }

  static String _classLabel(String id) {
    const map = {
      'class6':  'CLASS 6',
      'class7':  'CLASS 7',
      'class8':  'CLASS 8',
      'class9':  'CLASS 9',
      'class10': 'CLASS 10',
      'class11': 'CLASS 11',
      'class12': 'CLASS 12',
    };
    return map[id] ?? (id.isNotEmpty ? id.toUpperCase() : '');
  }

  static String _curriculumLabel(String id) {
    const map = {
      'punjab':    'PUNJAB CURRICULUM',
      'sindh':     'SINDH CURRICULUM',
      'federal':   'FEDERAL BOARD',
      'aga_khan':  'AGA KHAN BOARD',
      'cambridge': 'CAMBRIDGE',
    };
    return map[id] ?? (id.isNotEmpty ? id.toUpperCase() : '');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Class + curriculum chip + icons ──────────────────────────────
          Row(
            children: [
              if (_classChip.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    _classChip,
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.accentCyan,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Notification bell
              _HeaderIconButton(
                icon: Icons.notifications_outlined,
                onTap: () {},
              ),
              const SizedBox(width: 10),
              // Avatar
              _AvatarButton(initials: _initials),
            ],
          ),

          const SizedBox(height: 12),

          // ── Greeting ─────────────────────────────────────────────────────
          Text(
            '${_greeting()}, $_firstName',
            style: AppTextStyles.displayLarge,
          ),
          const SizedBox(height: 4),
          Text(
            _subText,
            style: AppTextStyles.body3,
          ),
        ],
      ),
    );
  }

  String get _subText {
    final h = DateTime.now().hour;
    if (h < 12) return 'Ready to start learning?';
    if (h < 17) return 'Ready to continue learning?';
    return 'Ready to continue learning?';
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor, width: 0.8),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  final String initials;
  const _AvatarButton({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyles.captionBold.copyWith(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
