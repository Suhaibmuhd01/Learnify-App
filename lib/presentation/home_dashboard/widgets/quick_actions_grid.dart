import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickActionsGrid extends StatelessWidget {
  final Function(String) onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actions = [
      {
        'id': 'practice_quiz',
        'title': 'Practice Quiz',
        'subtitle': 'Start learning',
        'icon': 'quiz',
        'color': colorScheme.primary,
      },
      {
        'id': 'battle_friends',
        'title': 'Battle Friends',
        'subtitle': 'Challenge others',
        'icon': 'sports_esports',
        'color': colorScheme.secondary,
      },
      {
        'id': 'browse_topics',
        'title': 'Browse Topics',
        'subtitle': 'Explore subjects',
        'icon': 'explore',
        'color': colorScheme.tertiary,
      },
      {
        'id': 'leaderboard',
        'title': 'Leaderboard',
        'subtitle': 'View rankings',
        'icon': 'leaderboard',
        'color': Colors.orange,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.4,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionCard(context, action);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, Map<String, dynamic> action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actionColor = action['color'] as Color;

    return GestureDetector(
      onTap: () => onActionTap(action['id'] as String),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: actionColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: actionColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onActionTap(action['id'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon Container
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: actionColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: action['icon'] as String,
                        color: actionColor,
                        size: 24,
                      ),
                    ),
                  ),
                  const Spacer(),

                  // Title and Subtitle
                  Text(
                    action['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    action['subtitle'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
