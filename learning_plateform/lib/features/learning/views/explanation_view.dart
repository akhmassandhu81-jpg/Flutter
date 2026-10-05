import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/learning/explanation_model.dart';

class ExplanationView extends StatelessWidget {
  final ExplanationModel explanation;

  const ExplanationView({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final paragraphs = explanation.content.split('\n\n');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded,
                    color: AppColors.accentCyan, size: 20),
              ),
              const SizedBox(width: 10),
              Text('EXPLANATION', style: AppTextStyles.label.copyWith(color: AppColors.accentCyan)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            explanation.title.isNotEmpty
                ? explanation.title
                : 'Educational Explanation',
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: 16),
          ...paragraphs.map((p) {
            if (p.startsWith('### ')) {
              return Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Text(
                  p.replaceFirst('### ', ''),
                  style: AppTextStyles.heading3.copyWith(color: AppColors.accentBlue),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                p,
                style: AppTextStyles.body1.copyWith(
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
