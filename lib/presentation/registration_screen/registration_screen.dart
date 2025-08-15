import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_progress_widget.dart';
import './widgets/social_registration_widget.dart';
import 'widgets/registration_form_widget.dart';
import 'widgets/registration_progress_widget.dart';
import 'widgets/social_registration_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final AuthService _authService = AuthService.instance;
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptTerms = false;
  int _currentStep = 0;
  final int _totalSteps = 3;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please accept the terms and conditions')));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          username: _usernameController.text.trim());

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Account created successfully! Please check your email to verify your account.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4)));

        // Navigate to login
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                'Registration failed: ${error.toString().replaceAll('Exception: Sign-up failed: ', '')}'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
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
            content: Text('Google sign-up failed: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _signUpWithApple() async {
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
            content: Text('Apple sign-up failed: $error'),
            backgroundColor: Colors.red));
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _signUpWithGoogleWrapper() {
    _signUpWithGoogle();
  }

  void _signUpWithAppleWrapper() {
    _signUpWithApple();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
                onPressed: () => Navigator.of(context).pop()),
            title: Text('Create Account',
                style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800]))),
        body: SafeArea(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress indicator
                      RegistrationProgressWidget(
                          currentStep: _currentStep, 
                          totalSteps: _totalSteps,
                          stepTitle: 'Step ${_currentStep + 1}'),

                      SizedBox(height: 4.h),

                      // App Logo and Title
                      Column(children: [
                        Container(
                            width: 16.w,
                            height: 16.w,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(3.w)),
                            child: Icon(Icons.school,
                                color: Colors.white, size: 8.w)),
                        SizedBox(height: 2.h),
                        Text('Join Learnify',
                            style: GoogleFonts.inter(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        SizedBox(height: 1.h),
                        Text('Start your gamified learning journey',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp, color: Colors.grey[600])),
                      ]),

                      SizedBox(height: 4.h),

                      // Registration Form
                      RegistrationFormWidget(
                          isLoading: _isLoading,
                          onFormDataChanged: (data) {},
                          onSubmit: _signUp),

                      SizedBox(height: 3.h),

                      // Navigation buttons
                      if (_currentStep < _totalSteps - 1) ...[
                        SizedBox(
                            width: double.infinity,
                            height: 6.h,
                            child: ElevatedButton(
                                onPressed: _nextStep,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w))),
                                child: Text('Next',
                                    style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600)))),
                      ] else ...[
                        // Sign Up Button
                        SizedBox(
                            width: double.infinity,
                            height: 6.h,
                            child: ElevatedButton(
                                onPressed: _isLoading ? null : _signUp,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w)),
                                    elevation: 2),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : Text('Create Account',
                                        style: GoogleFonts.inter(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600)))),
                      ],

                      if (_currentStep > 0) ...[
                        SizedBox(height: 2.h),
                        SizedBox(
                            width: double.infinity,
                            height: 5.h,
                            child: OutlinedButton(
                                onPressed: _previousStep,
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[600],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.w))),
                                child: Text('Previous',
                                    style: GoogleFonts.inter(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600)))),
                      ],

                      SizedBox(height: 3.h),

                      // Divider (only on first step)
                      if (_currentStep == 0) ...[
                        Row(children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: Text('OR',
                                  style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500))),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ]),

                        SizedBox(height: 3.h),

                        // Social Registration
                        SocialRegistrationWidget(
                            isLoading: _isLoading,
                            onGooglePressed: _isLoading ? null : _signUpWithGoogleWrapper,
                            onApplePressed: _isLoading ? null : _signUpWithAppleWrapper,
                            onFacebookPressed: null),

                        SizedBox(height: 3.h),
                      ],

                      // Sign In Link
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Already have an account? ",
                                style: GoogleFonts.inter(
                                    fontSize: 12.sp, color: Colors.grey[600])),
                            GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.login);
                                },
                                child: Text('Sign In',
                                    style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600))),
                          ]),
                    ]))));
  }
}