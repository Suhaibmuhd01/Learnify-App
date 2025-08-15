import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_banner.dart';
import './widgets/daily_challenge_card.dart';
import './widgets/quick_actions_grid.dart';
import './widgets/recent_activity_list.dart';
import './widgets/user_stats_card.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _currentBottomNavIndex = 0;
  Map<String, dynamic>? _currentAchievement;
  bool _isRefreshing = false;

  // Mock user data
  final Map<String, dynamic> _userData = {
    "username": "Suhaib Babangida",
    "avatar":
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face",
    "level": 12,
    "currentXP": 2450,
    "nextLevelXP": 3000,
    "totalPoints": 15750,
    "streak": 7,
  };

  // Mock daily challenge data
  final Map<String, dynamic> _dailyChallenge = {
    "title": "Math Mastery Challenge",
    "description": "Test your algebra skills with 10 challenging questions",
    "category": "Mathematics",
    "bonusPoints": 250,
    "timeRemaining": "18h 42m",
    "isCompleted": false,
  };

  // Mock recent activities
  final List<Map<String, dynamic>> _recentActivities = [
    {
      "type": "quiz_completed",
      "title": "Science Quiz Completed",
      "description": "Scored 85% in Biology Basics",
      "timestamp": "2 hours ago",
      "points": 120,
    },
    {
      "type": "badge_earned",
      "title": "Speed Demon Badge",
      "description": "Completed 5 quizzes in under 2 minutes each",
      "timestamp": "5 hours ago",
      "points": 200,
    },
    {
      "type": "level_up",
      "title": "Level Up!",
      "description": "Reached Level 12 - Keep up the great work!",
      "timestamp": "1 day ago",
      "points": 500,
    },
    {
      "type": "friend_achievement",
      "title": "Sarah completed History Quiz",
      "description": "Your friend Sarah just scored 92% in World History",
      "timestamp": "1 day ago",
      "points": null,
    },
    {
      "type": "streak_milestone",
      "title": "7-Day Streak!",
      "description": "You've maintained your learning streak for a week",
      "timestamp": "2 days ago",
      "points": 150,
    },
    {
      "type": "challenge_completed",
      "title": "Weekly Challenge Complete",
      "description": "Finished the English Grammar Challenge",
      "timestamp": "3 days ago",
      "points": 300,
    },
  ];

  @override
  void initState() {
    super.initState();
    _simulateAchievementNotification();
  }

  void _simulateAchievementNotification() {
    // Simulate an achievement notification after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentAchievement = {
            "title": "Quiz Master",
            "description": "Completed 50 quizzes with 80%+ accuracy",
            "points": 500,
          };
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // Update user stats (simulate new data)
        _userData["totalPoints"] = (_userData["totalPoints"] as int) + 50;
        _userData["currentXP"] = (_userData["currentXP"] as int) + 25;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dashboard updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleQuickAction(String actionId) {
    switch (actionId) {
      case 'practice_quiz':
        _showQuizOptions();
        break;
      case 'battle_friends':
        _showBattleOptions();
        break;
      case 'browse_topics':
        _showTopicBrowser();
        break;
      case 'leaderboard':
        Navigator.pushNamed(context, '/leaderboards');
        break;
    }
  }

  void _showQuizOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Choose Quiz Mode',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildQuizModeOption('Practice Mode',
                'Unlimited time, learn at your pace', 'school'),
            SizedBox(height: 2.h),
            _buildQuizModeOption(
                'Challenge Mode', 'Timed quizzes with streak rewards', 'timer'),
            SizedBox(height: 2.h),
            _buildQuizModeOption(
                'Battle Mode', '1v1 real-time competitions', 'sports_esports'),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizModeOption(
      String title, String description, String iconName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'arrow_forward_ios',
            color: colorScheme.onSurface.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showBattleOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Battle Friends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Challenge your friends to real-time quiz battles!',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Battle feature coming soon!')),
                );
              },
              icon: CustomIconWidget(
                iconName: 'sports_esports',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Start Battle'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showTopicBrowser() {
    final topics = [
      'Mathematics',
      'Science',
      'History',
      'English',
      'Geography',
      'Art'
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 60.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Browse Topics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected $topic')),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            topic,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserStatsDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: 70.h,
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Progress Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatDetail(
                        'Total Points', '${_userData["totalPoints"]}', 'stars'),
                    _buildStatDetail('Current Level',
                        'Level ${_userData["level"]}', 'trending_up'),
                    _buildStatDetail(
                        'Experience Points',
                        '${_userData["currentXP"]} / ${_userData["nextLevelXP"]}',
                        'psychology'),
                    _buildStatDetail('Learning Streak',
                        '${_userData["streak"]} days', 'local_fire_department'),
                    _buildStatDetail('Quizzes Completed', '127', 'quiz'),
                    _buildStatDetail('Average Score', '87%', 'analytics'),
                    _buildStatDetail('Badges Earned', '23', 'emoji_events'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDetail(String title, String value, String iconName) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Learnify',
        variant: CustomAppBarVariant.home,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Achievement Banner
              AchievementBanner(
                achievement: _currentAchievement,
                onDismiss: () {
                  setState(() {
                    _currentAchievement = null;
                  });
                },
              ),

              // User Stats Card
              UserStatsCard(
                userStats: _userData,
                onTap: _showUserStatsDetails,
              ),

              // Daily Challenge Card
              DailyChallengeCard(
                challengeData: _dailyChallenge,
                onStartChallenge: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Starting daily challenge...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Quick Actions Grid
              QuickActionsGrid(
                onActionTap: _handleQuickAction,
              ),

              SizedBox(height: 2.h),

              // Recent Activity List
              RecentActivityList(
                activities: _recentActivities,
              ),

              SizedBox(height: 10.h), // Bottom padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Create new quiz feature coming soon!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
        label: const Text('New Quiz'),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
        variant: CustomBottomBarVariant.main,
      ),
    );
  }
}
