import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../services/auth_service.dart';
import './widgets/achievements_gallery_widget.dart';
import './widgets/learning_goals_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/recent_activity_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/social_features_widget.dart';
import './widgets/statistics_cards_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  final AuthService _authService = AuthService.instance;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _achievements = [];
  List<dynamic> _recentQuizzes = [];
  bool _isLoading = true;
  bool _isSigningOut = false;
  int _currentBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await _authService.getUserProfile();
      final stats = await _authService.getUserStats();
      final achievements = await _authService.getUserAchievements();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _userStats = stats;
          _achievements = achievements;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: $error')));
      }
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.login, (Route<dynamic> route) => false);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSigningOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign out: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: CustomAppBar(title: 'Profile'),
          body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: CustomAppBar(title: 'My Profile', actions: [
          IconButton(
              icon: _isSigningOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.logout),
              onPressed: _isSigningOut ? null : _signOut),
        ]),
        body: RefreshIndicator(
            onRefresh: _loadUserData,
            child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header with enhanced data
                      ProfileHeaderWidget(
                        userData: _userProfile ?? {},
                        onChangePhoto: () {},
                        onEditProfile: () {},
                      ),
                      SizedBox(height: 3.h),

                      // Statistics Cards with real data
                      StatisticsCardsWidget(statistics: _userStats),
                      SizedBox(height: 3.h),

                      // Achievements Gallery with real data
                      AchievementsGalleryWidget(
                        achievements: _achievements,
                        onAchievementTap: (achievement) {},
                      ),
                      SizedBox(height: 3.h),

                      // Recent Activity with real data
                      RecentActivityWidget(activities: _recentQuizzes),
                      SizedBox(height: 3.h),

                      // Learning Goals with mock data (can be enhanced later)
                      LearningGoalsWidget(
                        goals: [],
                        onAddGoal: () {},
                      ),
                      SizedBox(height: 3.h),

                      // Social Features
                      SocialFeaturesWidget(
                        friends: [],
                        friendRequests: [],
                        onAcceptRequest: (request) {},
                        onDeclineRequest: (request) {},
                        onViewAllFriends: () {},
                      ),
                      SizedBox(height: 3.h),

                      // Settings Section
                      SettingsSectionWidget(
                        onAccountSettings: () {},
                        onNotificationSettings: () {},
                        onPrivacySettings: () {},
                        onSubscriptionManagement: () {},
                        onLogout: _signOut,
                      ),
                      SizedBox(height: 10.h), // Bottom padding for navigation
                    ]))),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _currentBottomNavIndex,
          onTap: (index) {
            setState(() {
              _currentBottomNavIndex = index;
            });
          },
        ));
  }
}