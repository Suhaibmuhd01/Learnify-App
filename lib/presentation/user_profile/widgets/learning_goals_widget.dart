import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LearningGoalsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> goals;
  final VoidCallback onAddGoal;

  const LearningGoalsWidget({
    super.key,
    required this.goals,
    required this.onAddGoal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learning Goals',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: onAddGoal,
              icon: CustomIconWidget(
                iconName: 'add_circle_outline',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              tooltip: 'Add Goal',
            ),
          ],
        ),
        SizedBox(height: 2.h),
        goals.isEmpty ? _buildEmptyState(context) : _buildGoalsList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'flag',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No learning goals set',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Set goals to track your learning progress',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: onAddGoal,
            icon: CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 4.w,
            ),
            label: const Text('Add Your First Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(BuildContext context) {
    return Column(
      children: goals.map((goal) => _buildGoalItem(context, goal)).toList(),
    );
  }

  Widget _buildGoalItem(BuildContext context, Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (goal["progress"] as num?)?.toDouble() ?? 0.0;
    final isCompleted = progress >= 1.0;

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: isCompleted
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getGoalColor(goal["category"] as String? ?? "")
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getGoalIcon(goal["category"] as String? ?? ""),
                  color: _getGoalColor(goal["category"] as String? ?? ""),
                  size: 5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal["title"] as String? ?? "Goal",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? colorScheme.onSurface.withValues(alpha: 0.6)
                            : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (goal["description"] != null) ...[
                      SizedBox(height: 0.5.h),
                      Text(
                        goal["description"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'check_circle',
                    color: Colors.green,
                    size: 5.w,
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isCompleted ? Colors.green : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Container(
            height: 0.8.h,
            decoration: BoxDecoration(
              color: (isCompleted ? Colors.green : colorScheme.primary)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          if (goal["deadline"] != null) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 4.w,
                ),
                SizedBox(width: 1.w),
                Text(
                  'Due: ${goal["deadline"]}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
          if (isCompleted && goal["completedDate"] != null) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Completed on ${goal["completedDate"]}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getGoalColor(String category) {
    switch (category.toLowerCase()) {
      case 'quiz':
        return Colors.blue;
      case 'streak':
        return Colors.orange;
      case 'subject':
        return Colors.green;
      case 'battle':
        return Colors.red;
      case 'social':
        return Colors.purple;
      default:
        return Colors.indigo;
    }
  }

  String _getGoalIcon(String category) {
    switch (category.toLowerCase()) {
      case 'quiz':
        return 'quiz';
      case 'streak':
        return 'local_fire_department';
      case 'subject':
        return 'school';
      case 'battle':
        return 'military_tech';
      case 'social':
        return 'group';
      default:
        return 'flag';
    }
  }
}
