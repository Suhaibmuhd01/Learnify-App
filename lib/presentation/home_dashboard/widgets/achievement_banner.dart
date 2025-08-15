import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AchievementBanner extends StatefulWidget {
  final Map<String, dynamic>? achievement;
  final VoidCallback onDismiss;

  const AchievementBanner({
    super.key,
    this.achievement,
    required this.onDismiss,
  });

  @override
  State<AchievementBanner> createState() => _AchievementBannerState();
}

class _AchievementBannerState extends State<AchievementBanner>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _celebrationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.elasticOut,
    ));

    if (widget.achievement != null) {
      _slideController.forward();
      _celebrationController.repeat(reverse: true);

      // Auto dismiss after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          _dismissBanner();
        }
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _dismissBanner() {
    _slideController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.achievement == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Card(
          elevation: 8,
          shadowColor: Colors.amber.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                // Achievement Icon with Animation
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'emoji_events',
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(width: 4.w),

                // Achievement Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '🎉 Achievement Unlocked!',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _dismissBanner,
                            icon: CustomIconWidget(
                              iconName: 'close',
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            constraints: BoxConstraints(
                              minWidth: 6.w,
                              minHeight: 6.w,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        widget.achievement!["title"] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        widget.achievement!["description"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Reward Info
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'stars',
                              color: Colors.orange,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '+${widget.achievement!["points"]} Points',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
