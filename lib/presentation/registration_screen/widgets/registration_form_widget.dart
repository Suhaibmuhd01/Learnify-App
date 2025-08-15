import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormDataChanged;
  final VoidCallback onSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    super.key,
    required this.onFormDataChanged,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;
  String _selectedAge = '';
  String _selectedGoal = '';
  List<String> _selectedInterests = [];

  final List<String> _ageRanges = [
    '13-17',
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+'
  ];

  final List<String> _learningGoals = [
    'Academic improvement',
    'Test preparation',
    'General knowledge',
    'Professional development'
  ];

  final List<String> _interests = [
    'Math',
    'Science',
    'History',
    'Languages',
    'Literature',
    'Geography',
    'Physics',
    'Chemistry'
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_updateFormData);
    _emailController.addListener(_updateFormData);
    _passwordController.addListener(_updateFormData);
    _confirmPasswordController.addListener(_updateFormData);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    final formData = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
      'age': _selectedAge,
      'goal': _selectedGoal,
      'interests': _selectedInterests,
      'termsAccepted': _termsAccepted,
    };
    widget.onFormDataChanged(formData);
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 8) return 'Fair';
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Strong';
    }
    return 'Good';
  }

  Color _getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return AppTheme.lightTheme.colorScheme.error;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return Colors.blue;
      case 'Strong':
        return AppTheme.lightTheme.colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  bool _isFormValid() {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.contains('@') &&
        _passwordController.text.length >= 6 &&
        _passwordController.text == _confirmPasswordController.text &&
        _selectedAge.isNotEmpty &&
        _selectedGoal.isNotEmpty &&
        _selectedInterests.isNotEmpty &&
        _termsAccepted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: CustomIconWidget(
                iconName: 'person',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Email Field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: CustomIconWidget(
                iconName: 'email',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          SizedBox(height: 2.h),

          // Password Field
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Create a strong password',
              prefixIcon: CustomIconWidget(
                iconName: 'lock',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility_off' : 'visibility',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),

          // Password Strength Indicator
          if (_passwordController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Row(
              children: [
                Text(
                  'Password strength: ',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  _getPasswordStrength(_passwordController.text),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPasswordStrengthColor(
                        _getPasswordStrength(_passwordController.text)),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          SizedBox(height: 2.h),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter your password',
              prefixIcon: CustomIconWidget(
                iconName: 'lock',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName: _isConfirmPasswordVisible
                      ? 'visibility_off'
                      : 'visibility',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          SizedBox(height: 3.h),

          // Age Selection
          Text(
            'Age Range',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _selectedAge.isEmpty ? null : _selectedAge,
            decoration: InputDecoration(
              hintText: 'Select your age range',
              prefixIcon: CustomIconWidget(
                iconName: 'cake',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            items: _ageRanges.map((age) {
              return DropdownMenuItem<String>(
                value: age,
                child: Text(age),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAge = value ?? '';
                _updateFormData();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your age range';
              }
              return null;
            },
          ),

          SizedBox(height: 3.h),

          // Educational Interests
          Text(
            'Educational Interests',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _interests.length,
              itemBuilder: (context, index) {
                final interest = _interests[index];
                final isSelected = _selectedInterests.contains(interest);

                return Container(
                  margin: EdgeInsets.only(right: 2.w),
                  child: FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                        _updateFormData();
                      });
                    },
                    selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                    checkmarkColor: colorScheme.primary,
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 3.h),

          // Learning Goals
          Text(
            'Learning Goals',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _selectedGoal.isEmpty ? null : _selectedGoal,
            decoration: InputDecoration(
              hintText: 'Select your learning goal',
              prefixIcon: CustomIconWidget(
                iconName: 'school',
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            items: _learningGoals.map((goal) {
              return DropdownMenuItem<String>(
                value: goal,
                child: Text(goal),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGoal = value ?? '';
                _updateFormData();
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your learning goal';
              }
              return null;
            },
          ),

          SizedBox(height: 3.h),

          // Terms and Conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _termsAccepted,
                onChanged: (value) {
                  setState(() {
                    _termsAccepted = value ?? false;
                    _updateFormData();
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _termsAccepted = !_termsAccepted;
                      _updateFormData();
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodySmall,
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: colorScheme.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Create Account Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  _isFormValid() && !widget.isLoading ? widget.onSubmit : null,
              child: widget.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Create Account',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
