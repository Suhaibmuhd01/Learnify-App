import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const RecentActivityList({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to full activity history
                  },
                  child: Text(
                    'View All',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length > 5 ? 5 : activities.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return _buildActivityItem(context, activity);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
      BuildContext context, Map<String, dynamic> activity) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activityType = activity["type"] as String;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          children: [
            // Activity Icon
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _getActivityColor(activityType, colorScheme)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _getActivityIcon(activityType),
                  color: _getActivityColor(activityType, colorScheme),
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),

            // Activity Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity["title"] as String,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    activity["description"] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Text(
                        activity["timestamp"] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      if (activity["points"] != null) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 1.5.w, vertical: 0.2.h),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'stars',
                                color: Colors.orange,
                                size: 12,
                              ),
                              SizedBox(width: 0.5.w),
                              Text(
                                '+${activity["points"]}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Social Actions (for friend activities)
            if (activityType == 'friend_achievement') ...[
              SizedBox(width: 2.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      // Handle like action
                    },
                    icon: CustomIconWidget(
                      iconName: 'favorite_border',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 8.w,
                      minHeight: 8.w,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Handle comment action
                    },
                    icon: CustomIconWidget(
                      iconName: 'chat_bubble_outline',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 8.w,
                      minHeight: 8.w,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getActivityIcon(String activityType) {
    switch (activityType) {
      case 'quiz_completed':
        return 'quiz';
      case 'badge_earned':
        return 'emoji_events';
      case 'level_up':
        return 'trending_up';
      case 'friend_achievement':
        return 'group';
      case 'streak_milestone':
        return 'local_fire_department';
      case 'challenge_completed':
        return 'flash_on';
      default:
        return 'notifications';
    }
  }

  Color _getActivityColor(String activityType, ColorScheme colorScheme) {
    switch (activityType) {
      case 'quiz_completed':
        return colorScheme.primary;
      case 'badge_earned':
        return Colors.amber;
      case 'level_up':
        return colorScheme.secondary;
      case 'friend_achievement':
        return colorScheme.tertiary;
      case 'streak_milestone':
        return Colors.orange;
      case 'challenge_completed':
        return Colors.purple;
      default:
        return colorScheme.onSurface;
    }
  }
}
