import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSectionWidget extends StatelessWidget {
  final VoidCallback onAccountSettings;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPrivacySettings;
  final VoidCallback onSubscriptionManagement;
  final VoidCallback onLogout;

  const SettingsSectionWidget({
    super.key,
    required this.onAccountSettings,
    required this.onNotificationSettings,
    required this.onPrivacySettings,
    required this.onSubscriptionManagement,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildSettingsCard(context),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            context,
            'Account Preferences',
            'Manage your account settings',
            'person',
            onAccountSettings,
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            'Notifications',
            'Control your notification preferences',
            'notifications',
            onNotificationSettings,
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            'Privacy',
            'Manage your privacy settings',
            'privacy_tip',
            onPrivacySettings,
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            'Subscription',
            'Manage your premium subscription',
            'card_membership',
            onSubscriptionManagement,
          ),
          _buildDivider(context),
          _buildSettingsItem(
            context,
            'Logout',
            'Sign out of your account',
            'logout',
            onLogout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isDestructive ? Colors.red : colorScheme.primary,
                size: 5.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? Colors.red : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color: colorScheme.outline.withValues(alpha: 0.1),
    );
  }
}
