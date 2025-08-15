import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import './custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool showValidation;
  final VoidCallback onForgotPassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.showValidation,
    required this.onForgotPassword,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ready to learn? Enter your email first! 📚';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Oops! That email format looks incorrect 🤔';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Your password is the key to knowledge! 🔑';
    }
    if (value.length < 6) {
      return 'Password should be at least 6 characters long 💪';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        CustomTextField(
          label: 'Email or Username',
          hint: 'Enter your email or username',
          iconName: 'email',
          controller: widget.emailController,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
          showValidation: widget.showValidation,
        ),
        SizedBox(height: 4.h),
        CustomTextField(
          label: 'Password',
          hint: 'Enter your password',
          iconName: 'lock',
          controller: widget.passwordController,
          isPassword: true,
          validator: _validatePassword,
          showValidation: widget.showValidation,
        ),
        SizedBox(height: 2.h),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: widget.onForgotPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}