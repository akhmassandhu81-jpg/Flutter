import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/learning/visualization_model.dart';

class VisualizationView extends StatelessWidget {
  final VisualizationModel visualization;

  const VisualizationView({super.key, required this.visualization});

  @override
  Widget build(BuildContext context) {
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
                  color: AppColors.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_tree_outlined,
                    color: AppColors.accentPurple, size: 20),
              ),
              const SizedBox(width: 10),
              Text('VISUALIZATION',
                  style: AppTextStyles.label.copyWith(color: AppColors.accentPurple)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            visualization.title.isNotEmpty
                ? visualization.title
                : 'Interactive Workflow',
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: 20),
          ...List.generate(visualization.steps.length, (index) {
            final step = visualization.steps[index];
            final isLast = index == visualization.steps.length - 1;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accentPurple.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.buttonSmall
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          step,
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      color: AppColors.accentPurple.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
