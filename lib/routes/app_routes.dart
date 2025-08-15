import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/leaderboards/leaderboards.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/auth_wrapper.dart';
import '../presentation/quiz_screen/quiz_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String userProfile = '/user-profile';
  static const String login = '/login-screen';
  static const String leaderboards = '/leaderboards';
  static const String registration = '/registration-screen';
  static const String authWrapper = '/auth-wrapper';
  static const String quizScreen = '/quiz-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const AuthWrapper(),
    splash: (context) => const SplashScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),
    leaderboards: (context) => const Leaderboards(),
    registration: (context) => const RegistrationScreen(),
    authWrapper: (context) => const AuthWrapper(),
    quizScreen: (context) => const QuizScreen(),
    // TODO: Add your other routes here
  };
}
