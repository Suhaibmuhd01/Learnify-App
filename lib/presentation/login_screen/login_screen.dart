import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/login_form.dart';
import './widgets/social_login_section.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/login_form.dart';
import 'widgets/social_login_button.dart';
import 'widgets/social_login_section.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeDashboard);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Sign-in failed: ${error.toString().replaceAll('Exception: Sign-in failed: ', '')}'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final success = await _authService.signInWithGoogle();
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeDashboard);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Google sign-in failed: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);

    try {
      final success = await _authService.signInWithApple();
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.homeDashboard);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Apple sign-in failed: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your email first')));
      return;
    }

    try {
      await _authService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send reset email: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8.h),

                      // App Logo and Title
                      Column(children: [
                        Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(4.w)),
                            child: Icon(Icons.school,
                                color: Colors.white, size: 10.w)),
                        SizedBox(height: 2.h),
                        Text('Learnify',
                            style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        SizedBox(height: 1.h),
                        Text('Gamified Learning Made Fun',
                            style: TextStyle(
                                fontSize: 14.sp, color: Colors.grey[600])),
                      ]),

                      SizedBox(height: 6.h),

                      // Login Form
                      LoginForm(
                          emailController: _emailController,
                          passwordController: _passwordController,
                          onForgotPassword: _forgotPassword,
                          showValidation: true),

                      SizedBox(height: 2.h),

                      // Forgot Password
                      Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: _forgotPassword,
                              child: Text('Forgot Password?',
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500)))),

                      SizedBox(height: 3.h),

                      // Sign In Button
                      SizedBox(
                          width: double.infinity,
                          height: 6.h,
                          child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(2.w)),
                                  elevation: 2),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : Text('Sign In',
                                      style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600)))),

                      SizedBox(height: 3.h),

                      // Divider
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Text('OR',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500))),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ]),

                      SizedBox(height: 3.h),

                      // Social Login Section
                      SocialLoginSection(onSocialLogin: (provider) async {
                        if (provider == 'google') {
                          await _signInWithGoogle();
                        } else if (provider == 'apple') {
                          await _signInWithApple();
                        }
                      }),

                      SizedBox(height: 4.h),

                      // Sign Up Link
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account? ",
                                style: TextStyle(
                                    fontSize: 12.sp, color: Colors.grey[600])),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed(AppRoutes.registration);
                                },
                                child: Text('Sign Up',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600))),
                          ]),

                      SizedBox(height: 4.h),

                      // Demo credentials
                      Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              border: Border.all(color: Colors.green.shade200),
                              borderRadius: BorderRadius.circular(2.w)),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Demo Credentials:',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700)),
                                SizedBox(height: 1.h),
                                Text(
                                    'Email: student@learnify.com\nPassword: password123',
                                    style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.green.shade600)),
                              ])),
                    ]))));
  }
}