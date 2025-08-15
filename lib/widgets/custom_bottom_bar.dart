import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom bottom navigation bar widget implementing educational app navigation patterns.
/// Features adaptive design with contextual navigation items and smooth transitions.
class CustomBottomBar extends StatelessWidget {
  /// The currently selected index
  final int currentIndex;

  /// Callback when a navigation item is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant type
  final CustomBottomBarVariant variant;

  /// Whether to show labels (optional)
  final bool showLabels;

  /// Custom background color (optional)
  final Color? backgroundColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.main,
    this.showLabels = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(context),
          ),
        ),
      ),
    );
  }

  /// Builds navigation items based on variant
  List<Widget> _buildNavigationItems(BuildContext context) {
    final items = _getNavigationItems();

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return _buildNavigationItem(
        context: context,
        item: item,
        isSelected: isSelected,
        onTap: () => _handleNavigation(context, index, item.route),
      );
    }).toList();
  }

  /// Builds individual navigation item
  Widget _buildNavigationItem({
    required BuildContext context,
    required NavigationItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final color =
        isSelected ? colorScheme.primary : colorScheme.onSurface.withAlpha(153);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withAlpha(26)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: color,
                  size: 24,
                ),
              ),
              if (showLabels) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Gets navigation items based on variant
  List<NavigationItem> _getNavigationItems() {
    switch (variant) {
      case CustomBottomBarVariant.main:
        return [
          NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            route: '/home-dashboard',
          ),
          NavigationItem(
            icon: Icons.quiz_outlined,
            selectedIcon: Icons.quiz,
            label: 'Quiz',
            route: '/home-dashboard', // Quiz section in home
          ),
          NavigationItem(
            icon: Icons.leaderboard_outlined,
            selectedIcon: Icons.leaderboard,
            label: 'Leaderboard',
            route: '/leaderboards',
          ),
          NavigationItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            route: '/user-profile',
          ),
        ];
      case CustomBottomBarVariant.learning:
        return [
          NavigationItem(
            icon: Icons.school_outlined,
            selectedIcon: Icons.school,
            label: 'Learn',
            route: '/home-dashboard',
          ),
          NavigationItem(
            icon: Icons.assignment_outlined,
            selectedIcon: Icons.assignment,
            label: 'Practice',
            route: '/home-dashboard',
          ),
          NavigationItem(
            icon: Icons.analytics_outlined,
            selectedIcon: Icons.analytics,
            label: 'Progress',
            route: '/user-profile',
          ),
          NavigationItem(
            icon: Icons.group_outlined,
            selectedIcon: Icons.group,
            label: 'Community',
            route: '/leaderboards',
          ),
        ];
      case CustomBottomBarVariant.minimal:
        return [
          NavigationItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            route: '/home-dashboard',
          ),
          NavigationItem(
            icon: Icons.leaderboard_outlined,
            selectedIcon: Icons.leaderboard,
            label: 'Leaderboard',
            route: '/leaderboards',
          ),
          NavigationItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: 'Profile',
            route: '/user-profile',
          ),
        ];
    }
  }

  /// Handles navigation when item is tapped
  void _handleNavigation(BuildContext context, int index, String route) {
    // Call the onTap callback to update the current index
    onTap(index);

    // Navigate to the appropriate route
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}

/// Navigation item data class
class NavigationItem {
  /// The icon to display when not selected
  final IconData icon;

  /// The icon to display when selected
  final IconData selectedIcon;

  /// The label text
  final String label;

  /// The route to navigate to
  final String route;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

/// Enum defining different bottom bar variants for educational contexts
enum CustomBottomBarVariant {
  /// Main navigation with home, quiz, leaderboard, and profile
  main,

  /// Learning-focused navigation with learn, practice, progress, and community
  learning,

  /// Minimal navigation with essential items only
  minimal,
}
