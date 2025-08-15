import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AchievementsGalleryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> achievements;
  final Function(Map<String, dynamic>) onAchievementTap;

  const AchievementsGalleryWidget({
    super.key,
    required this.achievements,
    required this.onAchievementTap,
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
              'Achievements',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => _showAllAchievements(context),
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
        achievements.isEmpty
            ? _buildEmptyState(context)
            : _buildAchievementsGrid(context),
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
            iconName: 'emoji_events',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No achievements yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Complete quizzes and challenges to earn badges',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(BuildContext context) {
    final displayAchievements = achievements.take(6).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 3.w,
        childAspectRatio: 1,
      ),
      itemCount: displayAchievements.length,
      itemBuilder: (context, index) {
        final achievement = displayAchievements[index];
        return _buildAchievementBadge(context, achievement);
      },
    );
  }

  Widget _buildAchievementBadge(
      BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlocked = achievement["unlocked"] as bool? ?? false;

    return GestureDetector(
      onTap: () => onAchievementTap(achievement),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? _getBadgeColor(achievement["category"] as String? ?? "")
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color:
                        _getBadgeColor(achievement["category"] as String? ?? "")
                            .withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getBadgeColor(achievement["category"] as String? ?? "")
                        .withValues(alpha: 0.1)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName:
                    _getBadgeIcon(achievement["category"] as String? ?? ""),
                color: isUnlocked
                    ? _getBadgeColor(achievement["category"] as String? ?? "")
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                size: 6.w,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement["name"] as String? ?? "Achievement",
              style: theme.textTheme.labelSmall?.copyWith(
                color: isUnlocked
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isUnlocked ? FontWeight.w500 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBadgeColor(String category) {
    switch (category.toLowerCase()) {
      case 'quiz':
        return Colors.blue;
      case 'streak':
        return Colors.orange;
      case 'battle':
        return Colors.red;
      case 'learning':
        return Colors.green;
      case 'social':
        return Colors.purple;
      default:
        return Colors.amber;
    }
  }

  String _getBadgeIcon(String category) {
    switch (category.toLowerCase()) {
      case 'quiz':
        return 'quiz';
      case 'streak':
        return 'local_fire_department';
      case 'battle':
        return 'military_tech';
      case 'learning':
        return 'school';
      case 'social':
        return 'group';
      default:
        return 'emoji_events';
    }
  }

  void _showAllAchievements(BuildContext context) {
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
                    'All Achievements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: EdgeInsets.all(4.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3.w,
                      mainAxisSpacing: 3.w,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      return _buildDetailedAchievementBadge(
                          context, achievements[index]);
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

  Widget _buildDetailedAchievementBadge(
      BuildContext context, Map<String, dynamic> achievement) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isUnlocked = achievement["unlocked"] as bool? ?? false;

    return GestureDetector(
      onTap: () => onAchievementTap(achievement),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? _getBadgeColor(achievement["category"] as String? ?? "")
                : colorScheme.outline.withValues(alpha: 0.2),
            width: isUnlocked ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getBadgeColor(achievement["category"] as String? ?? "")
                        .withValues(alpha: 0.1)
                    : colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName:
                    _getBadgeIcon(achievement["category"] as String? ?? ""),
                color: isUnlocked
                    ? _getBadgeColor(achievement["category"] as String? ?? "")
                    : colorScheme.onSurface.withValues(alpha: 0.3),
                size: 8.w,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              achievement["name"] as String? ?? "Achievement",
              style: theme.textTheme.labelMedium?.copyWith(
                color: isUnlocked
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: isUnlocked ? FontWeight.w500 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              SizedBox(height: 0.5.h),
              Text(
                achievement["dateEarned"] as String? ?? "",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
