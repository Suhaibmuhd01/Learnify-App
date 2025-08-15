import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialRegistrationWidget extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onFacebookPressed;
  final VoidCallback onApplePressed;
  final bool isLoading;

  const SocialRegistrationWidget({
    super.key,
    required this.onGooglePressed,
    required this.onFacebookPressed,
    required this.onApplePressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Social registration buttons
        Column(
          children: [
            // Google Sign Up
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onGooglePressed,
                icon: CustomImageWidget(
                  imageUrl:
                      'https://developers.google.com/identity/images/g-logo.png',
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                ),
                label: Text(
                  'Continue with Google',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Facebook Sign Up
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onFacebookPressed,
                icon: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1877F2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'facebook',
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                label: Text(
                  'Continue with Facebook',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Apple Sign Up (iOS style)
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onApplePressed,
                icon: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'apple',
                    color: Colors.white,
                    size: 12,
                  ),
                ),
                label: Text(
                  'Continue with Apple',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 4.h),

        // Login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login-screen');
              },
              child: Text(
                'Sign In',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
