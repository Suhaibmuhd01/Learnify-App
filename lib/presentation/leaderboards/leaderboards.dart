import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_leaderboard.dart';
import './widgets/leaderboard_header.dart';
import './widgets/leaderboard_tabs.dart';
import './widgets/podium_widget.dart';
import './widgets/search_filter_bar.dart';
import './widgets/time_period_selector.dart';
import './widgets/user_rank_card.dart';

class Leaderboards extends StatefulWidget {
  const Leaderboards({super.key});

  @override
  State<Leaderboards> createState() => _LeaderboardsState();
}

class _LeaderboardsState extends State<Leaderboards>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _selectedPeriod = 1; // Weekly by default
  int _currentBottomIndex = 2; // Leaderboard tab
  bool _isLoading = false;
  bool _isRefreshing = false;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Mock data for current user
  final Map<String, dynamic> _currentUser = {
    "id": "current_user",
    "username": "You",
    "avatar":
        "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
    "points": 1850,
    "level": 12,
    "rank": 15,
    "rankChange": 3,
  };

  // Mock leaderboard data
  final List<Map<String, dynamic>> _globalLeaderboard = [
    {
      "id": "1",
      "username": "Alex Chen",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 2450,
      "level": 18,
      "badge": "Quiz Master",
      "rankChange": 0,
    },
    {
      "id": "2",
      "username": "Sarah Kim",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 2180,
      "level": 16,
      "badge": "Speed Demon",
      "rankChange": 2,
    },
    {
      "id": "3",
      "username": "Usaid Babangida",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1920,
      "level": 15,
      "badge": "Streak King",
      "rankChange": -1,
    },
    {
      "id": "4",
      "username": "Emma Wilson",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1875,
      "level": 14,
      "badge": null,
      "rankChange": 1,
    },
    {
      "id": "5",
      "username": "David Brown",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1860,
      "level": 13,
      "badge": "Math Wizard",
      "rankChange": 0,
    },
    {
      "id": "current_user",
      "username": "You",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1850,
      "level": 12,
      "badge": null,
      "rankChange": 3,
    },
    {
      "id": "6",
      "username": "Lisa Garcia",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1820,
      "level": 12,
      "badge": "Science Star",
      "rankChange": -2,
    },
    {
      "id": "7",
      "username": "James Miller",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1780,
      "level": 11,
      "badge": null,
      "rankChange": 1,
    },
    {
      "id": "8",
      "username": "Anna Davis",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1750,
      "level": 11,
      "badge": "History Buff",
      "rankChange": 0,
    },
    {
      "id": "9",
      "username": "Ryan Taylor",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1720,
      "level": 10,
      "badge": null,
      "rankChange": -1,
    },
  ];

  final List<Map<String, dynamic>> _friendsLeaderboard = [
    {
      "id": "friend_1",
      "username": "Jessica Lee",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1950,
      "level": 15,
      "badge": "Best Friend",
      "rankChange": 1,
    },
    {
      "id": "current_user",
      "username": "You",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1850,
      "level": 12,
      "badge": null,
      "rankChange": 0,
    },
    {
      "id": "friend_2",
      "username": "Tom Wilson",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1680,
      "level": 11,
      "badge": "Study Buddy",
      "rankChange": -1,
    },
  ];

  final List<Map<String, dynamic>> _topicLeaderboard = [
    {
      "id": "topic_1",
      "username": "Math Genius",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 2850,
      "level": 20,
      "badge": "Math Master",
      "rankChange": 0,
    },
    {
      "id": "topic_2",
      "username": "Science Pro",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 2650,
      "level": 19,
      "badge": "Lab Expert",
      "rankChange": 1,
    },
    {
      "id": "current_user",
      "username": "You",
      "avatar":
          "https://cdn.pixabay.com/photo/2015/03/04/22/35/avatar-659652_640.png",
      "points": 1850,
      "level": 12,
      "badge": null,
      "rankChange": 2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadLeaderboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshLeaderboard() async {
    setState(() => _isRefreshing = true);

    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Leaderboard updated!'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedTab = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _onPeriodChanged(int index) {
    setState(() {
      _selectedPeriod = index;
    });
    _loadLeaderboardData();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentBottomIndex = index;
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Filter Leaderboard',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                children: [
                  _buildFilterSection('Subject Categories', [
                    'All Subjects',
                    'Mathematics',
                    'Science',
                    'History',
                    'Literature'
                  ]),
                  SizedBox(height: 3.h),
                  _buildFilterSection('Difficulty Levels',
                      ['All Levels', 'Easy', 'Medium', 'Hard']),
                  SizedBox(height: 3.h),
                  _buildFilterSection('Ranking Type', [
                    'Overall Points',
                    'Quiz Battles',
                    'Achievements',
                    'Streaks'
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...options.map((option) => ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: options.first,
                onChanged: (value) {},
              ),
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  void _onUserTap(Map<String, dynamic> user) {
    if (user["id"] == "current_user") {
      Navigator.pushNamed(context, '/user-profile');
    } else {
      _showUserProfile(user);
    }
  }

  void _showUserProfile(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1.w),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // User Avatar
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomImageWidget(
                        imageUrl: user["avatar"] as String,
                        width: 25.w,
                        height: 25.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Username
                  Text(
                    user["username"] as String,
                    style:
                        AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user["badge"] != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w),
                      ),
                      child: Text(
                        user["badge"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: 3.h),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Points',
                          '${(user["points"] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}'),
                      _buildStatItem('Level', '${user["level"]}'),
                      _buildStatItem(
                          'Rank', '#${_getCurrentRank(user["id"] as String)}'),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Challenge Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Challenge sent to ${user["username"]}!'),
                            backgroundColor:
                                AppTheme.lightTheme.colorScheme.primary,
                          ),
                        );
                      },
                      icon: CustomIconWidget(
                        iconName: 'sports_esports',
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        'Challenge to Battle',
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppTheme.lightTheme.colorScheme.primary,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  int _getCurrentRank(String userId) {
    final leaderboard = _getCurrentLeaderboard();
    final index = leaderboard.indexWhere((user) => user["id"] == userId);
    return index + 1;
  }

  List<Map<String, dynamic>> _getCurrentLeaderboard() {
    switch (_selectedTab) {
      case 0:
        return _globalLeaderboard;
      case 1:
        return _friendsLeaderboard;
      case 2:
        return _topicLeaderboard;
      default:
        return _globalLeaderboard;
    }
  }

  List<Map<String, dynamic>> _getTopThree() {
    final leaderboard = _getCurrentLeaderboard();
    return leaderboard.take(3).toList();
  }

  List<Map<String, dynamic>> _getFilteredLeaderboard() {
    final leaderboard = _getCurrentLeaderboard();
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) return leaderboard;

    return leaderboard.where((user) {
      final username = (user["username"] as String).toLowerCase();
      return username.contains(query);
    }).toList();
  }

  void _inviteFriends() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Invite link copied to clipboard!'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        action: SnackBarAction(
          label: 'Share',
          textColor: Colors.white,
          onPressed: () {
            // Handle share functionality
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaderboard = _getFilteredLeaderboard();
    final topThree = _getTopThree();
    final tabs = ['Global', 'Friends', 'Topics'];
    final periods = ['Daily', 'Weekly', 'Monthly', 'All-time'];

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Leaderboards',
        variant: CustomAppBarVariant.leaderboard,
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLeaderboard,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // User Header
              LeaderboardHeader(
                userRank: _currentUser["rank"] as int,
                userPoints: _currentUser["points"] as int,
                username: _currentUser["username"] as String,
                userAvatar: _currentUser["avatar"] as String,
                rankChange: _currentUser["rankChange"] as int,
              ),

              // Tab Selector
              LeaderboardTabs(
                selectedIndex: _selectedTab,
                onTabChanged: _onTabChanged,
                tabs: tabs,
              ),

              // Time Period Selector
              TimePeriodSelector(
                selectedPeriod: _selectedPeriod,
                onPeriodChanged: _onPeriodChanged,
                periods: periods,
              ),

              SizedBox(height: 2.h),

              // Search and Filter Bar
              SearchFilterBar(
                searchController: _searchController,
                onFilterTap: _showFilterDialog,
                onRefresh: _refreshLeaderboard,
                isLoading: _isRefreshing,
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                      )
                    : filteredLeaderboard.isEmpty
                        ? EmptyLeaderboard(
                            message: _selectedTab == 1
                                ? 'Add friends to see their rankings and compete together!'
                                : 'Be the first to start competing in this category!',
                            onInviteFriends:
                                _selectedTab == 1 ? _inviteFriends : null,
                          )
                        : ListView(
                            controller: _scrollController,
                            children: [
                              // Podium for top 3
                              if (topThree.length >= 3)
                                PodiumWidget(topThree: topThree),

                              SizedBox(height: 2.h),

                              // Leaderboard List
                              ...filteredLeaderboard
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final user = entry.value;
                                final rank = index + 1;
                                final isCurrentUser =
                                    user["id"] == "current_user";

                                return UserRankCard(
                                  user: user,
                                  rank: rank,
                                  isCurrentUser: isCurrentUser,
                                  onTap: () => _onUserTap(user),
                                );
                              }),

                              SizedBox(height: 10.h), // Bottom padding for FAB
                            ],
                          ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _onBottomNavTap,
        variant: CustomBottomBarVariant.main,
      ),
      floatingActionButton: filteredLeaderboard.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_up',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }
}
