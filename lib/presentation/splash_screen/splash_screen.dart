import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Splash Screen provides branded app launch experience while initializing core services
/// and determining user navigation path for the gamified learning platform.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _progressAnimation;

  double _initializationProgress = 0.0;
  String _currentTask = 'Initializing...';
  bool _hasError = false;
  bool _showRetry = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }

  /// Sets up all animations for the splash screen
  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Progress animation controller
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start logo animation
    _logoAnimationController.forward();
  }

  /// Starts the initialization process with simulated tasks
  Future<void> _startInitialization() async {
    try {
      _progressAnimationController.forward();

      // Task 1: Check authentication status
      await _updateProgress(0.2, 'Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Task 2: Load user preferences
      await _updateProgress(0.4, 'Loading preferences...');
      await Future.delayed(const Duration(milliseconds: 300));

      // Task 3: Fetch quiz categories
      await _updateProgress(0.6, 'Fetching quiz categories...');
      await Future.delayed(const Duration(milliseconds: 500));

      // Task 4: Sync offline data
      await _updateProgress(0.8, 'Syncing data...');
      await Future.delayed(const Duration(milliseconds: 400));

      // Task 5: Prepare gamification elements
      await _updateProgress(1.0, 'Preparing experience...');
      await Future.delayed(const Duration(milliseconds: 300));

      // Navigate based on authentication status
      await _navigateToNextScreen();
    } catch (e) {
      _handleInitializationError();
    }
  }

  /// Updates initialization progress with task description
  Future<void> _updateProgress(double progress, String task) async {
    if (mounted) {
      setState(() {
        _initializationProgress = progress;
        _currentTask = task;
      });
    }
  }

  /// Handles initialization errors with retry option
  void _handleInitializationError() {
    if (mounted) {
      setState(() {
        _hasError = true;
        _currentTask = 'Connection failed';
      });

      // Show retry option after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _hasError) {
          setState(() {
            _showRetry = true;
          });
        }
      });
    }
  }

  /// Retries the initialization process
  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _showRetry = false;
      _initializationProgress = 0.0;
      _currentTask = 'Retrying...';
    });

    _progressAnimationController.reset();
    _startInitialization();
  }

  /// Navigates to the appropriate next screen based on user state
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Simulate authentication check
    final bool isAuthenticated = _checkAuthenticationStatus();
    final bool isFirstTime = _checkFirstTimeUser();

    String nextRoute;
    if (isAuthenticated) {
      nextRoute = '/home-dashboard';
    } else if (isFirstTime) {
      // For now, navigate to login as onboarding is not in available routes
      nextRoute = '/login-screen';
    } else {
      nextRoute = '/login-screen';
    }

    // Smooth fade transition to next screen
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  /// Simulates authentication status check
  bool _checkAuthenticationStatus() {
    // In real implementation, check stored tokens/session
    return false; // Default to not authenticated for demo
  }

  /// Simulates first time user check
  bool _checkFirstTimeUser() {
    // In real implementation, check if user has completed onboarding
    return true; // Default to first time for demo
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: _buildGradientBackground(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildLogoSection(),
                ),
                Expanded(
                  flex: 1,
                  child: _buildProgressSection(),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the vibrant gradient background
  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.lightTheme.colorScheme.primary,
          AppTheme.lightTheme.colorScheme.secondary,
          AppTheme.lightTheme.colorScheme.tertiary,
        ],
        stops: const [0.0, 0.6, 1.0],
      ),
    );
  }

  /// Builds the animated logo section
  Widget _buildLogoSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _logoAnimationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _logoFadeAnimation,
            child: ScaleTransition(
              scale: _logoScaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppLogo(),
                  SizedBox(height: 3.h),
                  _buildAppTitle(),
                  SizedBox(height: 1.h),
                  _buildTagline(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the app logo with educational gaming elements
  Widget _buildAppLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main logo icon
          CustomIconWidget(
            iconName: 'school',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 12.w,
          ),
          // Gaming element - small star
          Positioned(
            top: 2.w,
            right: 2.w,
            child: Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'star',
                color: Colors.white,
                size: 2.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the app title
  Widget _buildAppTitle() {
    return Text(
      'Learnify',
      style: AppTheme.lightTheme.textTheme.displaySmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  /// Builds the tagline
  Widget _buildTagline() {
    return Text(
      'Learn • Play • Achieve',
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        letterSpacing: 0.8,
      ),
    );
  }

  /// Builds the progress section with animated indicator
  Widget _buildProgressSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProgressIndicator(),
          SizedBox(height: 2.h),
          _buildTaskDescription(),
          if (_showRetry) ...[
            SizedBox(height: 2.h),
            _buildRetryButton(),
          ],
        ],
      ),
    );
  }

  /// Builds the animated progress indicator
  Widget _buildProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // Progress bar
            Container(
              width: double.infinity,
              height: 0.8.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(0.4.h),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _hasError ? 0.0 : _initializationProgress,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(0.4.h),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            // Progress percentage
            if (!_hasError)
              Text(
                '${(_initializationProgress * 100).toInt()}%',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        );
      },
    );
  }

  /// Builds the current task description
  Widget _buildTaskDescription() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _currentTask,
        key: ValueKey(_currentTask),
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: _hasError
              ? Colors.red.shade200
              : Colors.white.withValues(alpha: 0.9),
          fontWeight: FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Builds the retry button when initialization fails
  Widget _buildRetryButton() {
    return ElevatedButton(
      onPressed: _retryInitialization,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.lightTheme.colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.h),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'refresh',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 2.w),
          Text(
            'Retry',
            style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
