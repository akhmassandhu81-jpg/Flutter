import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/subject_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';

/// Single subject card in the 2-column grid.
class SubjectCard extends StatelessWidget {
  final SubjectModel subject;
  final SubjectProgressModel progress;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasProgress = !progress.isNotStarted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Icon + status ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SubjectIcon(
                  label:   subject.iconLabel,
                  bgColor: subject.iconBgColor,
                  fgColor: subject.iconColor,
                ),
                Flexible(
                  child: Text(
                    hasProgress
                        ? '${progress.progressPercent.toStringAsFixed(0)}%'
                        : 'Not started',
                    style: AppTextStyles.caption.copyWith(
                      color: hasProgress
                          ? AppColors.textSecondary
                          : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Subject name ───────────────────────────────────────────────
            Text(
              subject.name,
              style: AppTextStyles.heading3.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            // ── Progress bar ───────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (progress.progressPercent / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(subject.iconColor),
                minHeight: 4,
              ),
            ),

            const SizedBox(height: 6),

            // ── Start / Continue label ─────────────────────────────────────
            Row(
              children: [
                Text(
                  hasProgress ? 'Continue' : 'Start Learning',
                  style: AppTextStyles.captionBold.copyWith(
                    color: subject.iconColor,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: subject.iconColor, size: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectIcon extends StatelessWidget {
  final String label;
  final Color  bgColor;
  final Color  fgColor;

  const _SubjectIcon({
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color:      fgColor,
            fontSize:   label.length > 2 ? 11 : 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
