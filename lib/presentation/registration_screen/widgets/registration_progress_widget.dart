import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RegistrationProgressWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  const RegistrationProgressWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = currentStep / totalSteps;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Step $currentStep of $totalSteps',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          SizedBox(height: 1.h),

          // Progress percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progress * 100).toInt()}% Complete',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Row(
                children: List.generate(totalSteps, (index) {
                  final isCompleted = index < currentStep;
                  final isCurrent = index == currentStep - 1;

                  return Container(
                    margin: EdgeInsets.only(left: index > 0 ? 1.w : 0),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: isCurrent
                          ? Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
