import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar widget implementing contextual design patterns for educational applications.
/// Features adaptive behavior with SliverAppBar functionality and contextual actions.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The title to display in the app bar
  final String title;

  /// Whether to show the back button (optional)
  final bool showBackButton;

  /// Custom leading widget (optional)
  final Widget? leading;

  /// List of action widgets (optional)
  final List<Widget>? actions;

  /// Whether the app bar should be elevated (optional)
  final bool elevated;

  /// Custom background color (optional)
  final Color? backgroundColor;

  /// Custom foreground color (optional)
  final Color? foregroundColor;

  /// Whether to center the title (optional)
  final bool centerTitle;

  /// App bar variant type
  final CustomAppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.leading,
    this.actions,
    this.elevated = false,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.variant = CustomAppBarVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: _getTitleStyle(theme),
      ),
      leading: _buildLeading(context),
      actions: _buildActions(context),
      backgroundColor: _getBackgroundColor(colorScheme),
      foregroundColor: _getForegroundColor(colorScheme),
      elevation: _getElevation(),
      scrolledUnderElevation: _getScrolledUnderElevation(),
      shadowColor: _getShadowColor(colorScheme),
      surfaceTintColor: Colors.transparent,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
    );
  }

  /// Builds the leading widget based on configuration
  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  /// Builds the actions list with educational app specific actions
  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add variant-specific actions
    switch (variant) {
      case CustomAppBarVariant.home:
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _handleNotifications(context),
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => _navigateToProfile(context),
            tooltip: 'Profile',
          ),
        ]);
        break;
      case CustomAppBarVariant.quiz:
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showQuizHelp(context),
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showQuizSettings(context),
            tooltip: 'Quiz Settings',
          ),
        ]);
        break;
      case CustomAppBarVariant.leaderboard:
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showLeaderboardFilters(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshLeaderboard(context),
            tooltip: 'Refresh',
          ),
        ]);
        break;
      case CustomAppBarVariant.profile:
        actionWidgets.addAll([
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editProfile(context),
            tooltip: 'Edit Profile',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showProfileSettings(context),
            tooltip: 'Settings',
          ),
        ]);
        break;
      case CustomAppBarVariant.standard:
        // No additional actions for standard variant
        break;
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  /// Gets the title text style based on theme
  TextStyle _getTitleStyle(ThemeData theme) {
    return GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: _getForegroundColor(theme.colorScheme),
    );
  }

  /// Gets the background color based on variant and theme
  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case CustomAppBarVariant.home:
        return colorScheme.surface;
      case CustomAppBarVariant.quiz:
        return colorScheme.primaryContainer.withAlpha(26);
      case CustomAppBarVariant.leaderboard:
        return colorScheme.surface;
      case CustomAppBarVariant.profile:
        return colorScheme.surface;
      case CustomAppBarVariant.standard:
        return colorScheme.surface;
    }
  }

  /// Gets the foreground color based on variant and theme
  Color _getForegroundColor(ColorScheme colorScheme) {
    if (foregroundColor != null) return foregroundColor!;
    return colorScheme.onSurface;
  }

  /// Gets the elevation based on configuration
  double _getElevation() {
    if (elevated) return 2.0;
    return 0.0;
  }

  /// Gets the scrolled under elevation
  double _getScrolledUnderElevation() {
    return elevated ? 4.0 : 2.0;
  }

  /// Gets the shadow color based on theme
  Color _getShadowColor(ColorScheme colorScheme) {
    return colorScheme.shadow;
  }

  // Action handlers for different variants
  void _handleNotifications(BuildContext context) {
    // Show notifications bottom sheet or navigate to notifications screen
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Notifications',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            const Text('No new notifications'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, '/user-profile');
  }

  void _showQuizHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quiz Help',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Tap on the correct answer to proceed. You can review your progress at any time.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showQuizSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quiz Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Timer'),
              trailing: Switch(value: true, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Sound Effects'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLeaderboardFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Leaderboard',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('This Week'),
              leading: Radio(value: 1, groupValue: 1, onChanged: (value) {}),
            ),
            ListTile(
              title: const Text('This Month'),
              leading: Radio(value: 2, groupValue: 1, onChanged: (value) {}),
            ),
            ListTile(
              title: const Text('All Time'),
              leading: Radio(value: 3, groupValue: 1, onChanged: (value) {}),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _refreshLeaderboard(BuildContext context) {
    // Trigger leaderboard refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing leaderboard...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    // Navigate to profile edit screen or show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit profile functionality'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProfileSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Profile Settings',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => Navigator.pushNamed(context, '/login-screen'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enum defining different app bar variants for educational contexts
enum CustomAppBarVariant {
  /// Standard app bar with basic functionality
  standard,

  /// Home screen app bar with notifications and profile access
  home,

  /// Quiz screen app bar with help and settings
  quiz,

  /// Leaderboard app bar with filters and refresh
  leaderboard,

  /// Profile screen app bar with edit and settings
  profile,
}
