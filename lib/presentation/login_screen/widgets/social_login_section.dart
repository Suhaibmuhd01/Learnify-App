import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import './social_login_button.dart';

class SocialLoginSection extends StatefulWidget {
  final Function(String) onSocialLogin;

  const SocialLoginSection({
    super.key,
    required this.onSocialLogin,
  });

  @override
  State<SocialLoginSection> createState() => _SocialLoginSectionState();
}

class _SocialLoginSectionState extends State<SocialLoginSection> {
  String? _loadingProvider;

  void _handleSocialLogin(String provider) async {
    setState(() => _loadingProvider = provider);

    try {
      await widget.onSocialLogin(provider);
    } finally {
      if (mounted) {
        setState(() => _loadingProvider = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: colorScheme.outline.withValues(alpha: 0.3),
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Expanded(
              child: SocialLoginButton(
                iconName: 'g_translate',
                label: 'Google',
                backgroundColor: colorScheme.surface,
                textColor: colorScheme.onSurface,
                onPressed: () => _handleSocialLogin('google'),
                isLoading: _loadingProvider == 'google',
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: SocialLoginButton(
                iconName: 'facebook',
                label: 'Facebook',
                backgroundColor: const Color(0xFF1877F2),
                textColor: Colors.white,
                onPressed: () => _handleSocialLogin('facebook'),
                isLoading: _loadingProvider == 'facebook',
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        SocialLoginButton(
          iconName: 'apple',
          label: 'Continue with Apple',
          backgroundColor: colorScheme.onSurface,
          textColor: colorScheme.surface,
          onPressed: () => _handleSocialLogin('apple'),
          isLoading: _loadingProvider == 'apple',
        ),
      ],
    );
  }
}