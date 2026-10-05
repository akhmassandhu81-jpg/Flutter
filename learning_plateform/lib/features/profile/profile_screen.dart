import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/features/profile/widgets/edit_profile_sheet.dart';
import 'package:learning_plateform/models/user_model.dart';
import 'package:learning_plateform/providers/auth_providers.dart';
import 'package:learning_plateform/providers/bookmark_provider.dart';
import 'package:learning_plateform/providers/progress_provider.dart';
import 'package:learning_plateform/services/auth_service.dart';
import 'package:learning_plateform/widgets/app_bottom_nav_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Profile', style: AppTextStyles.heading1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Profile',
            onPressed: () => ref.invalidate(userProfileProvider),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const _ProfileLoadingSkeleton(),
        error: (err, _) => _ProfileError(
          onRetry: () => ref.invalidate(userProfileProvider),
        ),
        data: (profile) {
          if (profile.uid.isEmpty) {
            return const _ProfileLoadingSkeleton();
          }
          return _ProfileContent(user: profile);
        },
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _ProfileContent extends ConsumerWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

  String get _initials {
    final parts = user.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return user.fullName.isNotEmpty
        ? user.fullName.substring(0, user.fullName.length.clamp(0, 2)).toUpperCase()
        : 'S';
  }

  String get _classLabel {
    final cl = user.classLevel ?? 'class6';
    const map = {
      'class6':  'Class 6',
      'class7':  'Class 7',
      'class8':  'Class 8',
      'class9':  'Class 9',
      'class10': 'Class 10',
      'class11': 'Class 11',
      'class12': 'Class 12',
    };
    return map[cl] ?? (cl.isNotEmpty ? cl.toUpperCase() : 'Class 6');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressDetailsStateProvider);
    final bookmarksAsync = ref.watch(userBookmarksStreamProvider);

    final overallPercent =
        progressAsync.valueOrNull?.summary.overallPercent ?? 0.0;
    final bookmarkCount =
        bookmarksAsync.valueOrNull?.length ?? 0;
    final subjectCount =
        user.hasSelectedSubjects ? user.selectedSubjectIds.length : 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ── Profile Header Card ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initials,
                        style: AppTextStyles.displayLarge
                            .copyWith(color: Colors.white, fontSize: 26),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : 'Student',
                    style: AppTextStyles.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email, style: AppTextStyles.body2),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.accentCyan.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'STUDENT • ${_classLabel.toUpperCase()}',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.accentCyan,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Learning Summary Card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEARNING SUMMARY',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.menu_book_rounded,
                          iconColor: AppColors.accentBlue,
                          value: '$subjectCount',
                          label: 'Subjects',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.bar_chart_rounded,
                          iconColor: AppColors.accentCyan,
                          value: '${overallPercent.toStringAsFixed(0)}%',
                          label: 'Progress',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryTile(
                          icon: Icons.bookmark_rounded,
                          iconColor: AppColors.accentPurple,
                          value: '$bookmarkCount',
                          label: 'Bookmarks',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Account Information Card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACCOUNT DETAILS',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: 'Full Name',
                    value: user.fullName.isNotEmpty ? user.fullName : 'Student',
                  ),
                  const Divider(color: AppColors.dividerColor, height: 16),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email,
                  ),
                  const Divider(color: AppColors.dividerColor, height: 16),
                  _InfoRow(
                    icon: Icons.school_outlined,
                    label: 'Class Level',
                    value: _classLabel,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Account Actions ───────────────────────────────────────────
            // Edit Profile Action
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => EditProfileSheet(user: user),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderColor, width: 0.8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: AppColors.accentBlue, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Edit Profile',
                          style: AppTextStyles.heading3.copyWith(fontSize: 15)),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sign Out Action
            GestureDetector(
              onTap: () => _showLogoutDialog(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded,
                          color: AppColors.error, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Log Out',
                        style: AppTextStyles.heading3
                            .copyWith(color: AppColors.error, fontSize: 15),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.error),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Out', style: AppTextStyles.heading2),
        content: Text(
          'Are you sure you want to log out of LMS Arena?',
          style: AppTextStyles.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: AppTextStyles.buttonSmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.instance.logout();
            },
            child: Text('Log Out', style: AppTextStyles.buttonSmall),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _SummaryTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.statLabel),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.accentBlue, size: 20),
        const SizedBox(width: 12),
        Text(label, style: AppTextStyles.body2),
        const Spacer(),
        Text(value,
            style: AppTextStyles.heading3
                .copyWith(fontSize: 14, color: AppColors.textPrimary)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOADING SKELETON
// ══════════════════════════════════════════════════════════════════════════════
class _ProfileLoadingSkeleton extends StatelessWidget {
  const _ProfileLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _ShimmerCard(height: 180, radius: 20),
            const SizedBox(height: 20),
            _ShimmerCard(height: 100, radius: 16),
            const SizedBox(height: 20),
            _ShimmerCard(height: 140, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final double height;
  final double radius;

  const _ShimmerCard({required this.height, required this.radius});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ══════════════════════════════════════════════════════════════════════════════
class _ProfileError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProfileError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text('Unable to load profile.', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text('Please check your connection and try again.',
                style: AppTextStyles.body3, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Retry', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
