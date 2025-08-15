import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityWidget extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityWidget({
    super.key,
    required this.activities,
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
              'Recent Activity',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _showAllActivities(context),
              child: Text(
                'View All',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        activities.isEmpty
            ? _buildEmptyState(context)
            : _buildActivityTimeline(context),
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
            iconName: 'history',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No recent activity',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Start taking quizzes to see your activity here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(BuildContext context) {
    final displayActivities = activities.take(5).toList();

    return Column(
      children: displayActivities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final isLast = index == displayActivities.length - 1;

        return _buildActivityItem(context, activity, isLast);
      }).toList(),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity, bool isLast) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activityType = activity["type"] as String? ?? "unknown";

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 3.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _getActivityColor(activityType).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _getActivityColor(activityType),
                    width: 2,
                  ),
                ),
                child: CustomIconWidget(
                  iconName: _getActivityIcon(activityType),
                  color: _getActivityColor(activityType),
                  size: 5.w,
                ),
              ),
              if (!isLast) ...[
                Container(
                  width: 2,
                  height: 8.w,
                  margin: EdgeInsets.symmetric(vertical: 1.w),
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity["title"] as String? ?? "Activity",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (activity["description"] != null) ...[
                    SizedBox(height: 1.h),
                    Text(
                      activity["description"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (activity["points"] != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'stars',
                                color: Colors.amber,
                                size: 3.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '+${activity["points"]}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        activity["timestamp"] as String? ?? "",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Colors.blue;
      case 'achievement':
        return Colors.amber;
      case 'battle':
        return Colors.red;
      case 'streak':
        return Colors.orange;
      case 'social':
        return Colors.purple;
      case 'learning':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return 'quiz';
      case 'achievement':
        return 'emoji_events';
      case 'battle':
        return 'military_tech';
      case 'streak':
        return 'local_fire_department';
      case 'social':
        return 'group';
      case 'learning':
        return 'school';
      default:
        return 'circle';
    }
  }

  void _showAllActivities(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    'All Activities',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(4.w),
                    itemCount: activities.length,
                    itemBuilder: (context, index) {
                      return _buildActivityItem(
                        context,
                        activities[index],
                        index == activities.length - 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
