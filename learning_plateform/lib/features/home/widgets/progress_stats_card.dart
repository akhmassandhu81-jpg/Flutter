import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/progress_model.dart';

/// "YOUR PROGRESS — This Week" row of four stat tiles.
class ProgressStatsCard extends StatelessWidget {
  final ProgressModel progress;

  const ProgressStatsCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── Section header ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('YOUR PROGRESS',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 1.2,
                  )),
              Text('This Week',
                  style: AppTextStyles.captionBold.copyWith(
                    color: AppColors.accentCyan,
                  )),
            ],
          ),
          const SizedBox(height: 12),

          // ── Four stat tiles ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.bar_chart_rounded,
                  iconColor: AppColors.accentBlue,
                  value: '${progress.overallPercent.toStringAsFixed(0)}%',
                  label: 'Overall',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.accentCyan,
                  value: '${progress.quizAccuracy.toStringAsFixed(0)}%',
                  label: 'Accuracy',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppColors.accentOrange,
                  value: '${progress.streakDays} Days',
                  label: 'Streak',
                  valueSize: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  icon: Icons.check_rounded,
                  iconColor: AppColors.accentPurple,
                  value: '${progress.completedTopics}',
                  label: 'Topics',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final String   value;
  final String   label;
  final double   valueSize;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.statValue.copyWith(fontSize: valueSize),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.statLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
