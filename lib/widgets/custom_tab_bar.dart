import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom tab bar widget implementing educational app tab navigation patterns.
/// Features adaptive design with contextual tabs and smooth animations.
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  /// The tab controller
  final TabController controller;

  /// List of tab labels
  final List<String> tabs;

  /// Tab bar variant type
  final CustomTabBarVariant variant;

  /// Whether tabs are scrollable (optional)
  final bool isScrollable;

  /// Custom background color (optional)
  final Color? backgroundColor;

  /// Custom indicator color (optional)
  final Color? indicatorColor;

  /// Custom label color (optional)
  final Color? labelColor;

  /// Custom unselected label color (optional)
  final Color? unselectedLabelColor;

  const CustomTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.variant = CustomTabBarVariant.standard,
    this.isScrollable = false,
    this.backgroundColor,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? _getBackgroundColor(colorScheme),
        boxShadow: variant == CustomTabBarVariant.elevated
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TabBar(
        controller: controller,
        tabs: _buildTabs(),
        isScrollable: isScrollable,
        labelColor: labelColor ?? _getLabelColor(colorScheme),
        unselectedLabelColor:
            unselectedLabelColor ?? _getUnselectedLabelColor(colorScheme),
        indicatorColor: indicatorColor ?? _getIndicatorColor(colorScheme),
        indicatorWeight: _getIndicatorWeight(),
        indicatorSize: _getIndicatorSize(),
        labelStyle: _getLabelStyle(),
        unselectedLabelStyle: _getUnselectedLabelStyle(),
        labelPadding: _getLabelPadding(),
        indicator: _buildIndicator(colorScheme),
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.all(
          colorScheme.primary.withAlpha(26),
        ),
      ),
    );
  }

  /// Builds the list of tabs
  List<Widget> _buildTabs() {
    return tabs.map((tabLabel) {
      switch (variant) {
        case CustomTabBarVariant.withIcons:
          return Tab(
            icon: _getTabIcon(tabLabel),
            text: tabLabel,
          );
        case CustomTabBarVariant.iconOnly:
          return Tab(
            icon: _getTabIcon(tabLabel),
          );
        case CustomTabBarVariant.standard:
        case CustomTabBarVariant.elevated:
        case CustomTabBarVariant.rounded:
          return Tab(text: tabLabel);
      }
    }).toList();
  }

  /// Gets the appropriate icon for a tab label
  Icon _getTabIcon(String label) {
    switch (label.toLowerCase()) {
      case 'overview':
      case 'home':
        return const Icon(Icons.home_outlined, size: 20);
      case 'progress':
      case 'stats':
        return const Icon(Icons.analytics_outlined, size: 20);
      case 'achievements':
      case 'badges':
        return const Icon(Icons.emoji_events_outlined, size: 20);
      case 'settings':
        return const Icon(Icons.settings_outlined, size: 20);
      case 'quiz':
      case 'test':
        return const Icon(Icons.quiz_outlined, size: 20);
      case 'learn':
      case 'study':
        return const Icon(Icons.school_outlined, size: 20);
      case 'practice':
        return const Icon(Icons.assignment_outlined, size: 20);
      case 'review':
        return const Icon(Icons.rate_review_outlined, size: 20);
      case 'leaderboard':
      case 'ranking':
        return const Icon(Icons.leaderboard_outlined, size: 20);
      case 'friends':
      case 'social':
        return const Icon(Icons.group_outlined, size: 20);
      default:
        return const Icon(Icons.tab, size: 20);
    }
  }

  /// Gets background color based on variant
  Color _getBackgroundColor(ColorScheme colorScheme) {
    switch (variant) {
      case CustomTabBarVariant.elevated:
        return colorScheme.surface;
      case CustomTabBarVariant.rounded:
        return colorScheme.surfaceContainerHighest;
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.withIcons:
      case CustomTabBarVariant.iconOnly:
        return Colors.transparent;
    }
  }

  /// Gets label color
  Color _getLabelColor(ColorScheme colorScheme) {
    return colorScheme.primary;
  }

  /// Gets unselected label color
  Color _getUnselectedLabelColor(ColorScheme colorScheme) {
    return colorScheme.onSurface.withAlpha(153);
  }

  /// Gets indicator color
  Color _getIndicatorColor(ColorScheme colorScheme) {
    return colorScheme.primary;
  }

  /// Gets indicator weight based on variant
  double _getIndicatorWeight() {
    switch (variant) {
      case CustomTabBarVariant.elevated:
      case CustomTabBarVariant.rounded:
        return 3.0;
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.withIcons:
      case CustomTabBarVariant.iconOnly:
        return 2.0;
    }
  }

  /// Gets indicator size
  TabBarIndicatorSize _getIndicatorSize() {
    return TabBarIndicatorSize.label;
  }

  /// Gets label text style
  TextStyle _getLabelStyle() {
    return GoogleFonts.inter(
      fontSize: variant == CustomTabBarVariant.iconOnly ? 0 : 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    );
  }

  /// Gets unselected label text style
  TextStyle _getUnselectedLabelStyle() {
    return GoogleFonts.inter(
      fontSize: variant == CustomTabBarVariant.iconOnly ? 0 : 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
    );
  }

  /// Gets label padding
  EdgeInsetsGeometry _getLabelPadding() {
    switch (variant) {
      case CustomTabBarVariant.withIcons:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case CustomTabBarVariant.iconOnly:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.elevated:
      case CustomTabBarVariant.rounded:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  /// Builds custom indicator based on variant
  Decoration? _buildIndicator(ColorScheme colorScheme) {
    switch (variant) {
      case CustomTabBarVariant.rounded:
        return BoxDecoration(
          color: colorScheme.primary.withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary,
            width: 1,
          ),
        );
      case CustomTabBarVariant.elevated:
        return BoxDecoration(
          color: colorScheme.primary,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(4),
          ),
        );
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.withIcons:
      case CustomTabBarVariant.iconOnly:
        return UnderlineTabIndicator(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        );
    }
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomTabBarVariant.withIcons:
        return const Size.fromHeight(72);
      case CustomTabBarVariant.iconOnly:
        return const Size.fromHeight(56);
      case CustomTabBarVariant.standard:
      case CustomTabBarVariant.elevated:
      case CustomTabBarVariant.rounded:
        return const Size.fromHeight(48);
    }
  }
}

/// Enum defining different tab bar variants for educational contexts
enum CustomTabBarVariant {
  /// Standard tab bar with text labels only
  standard,

  /// Tab bar with icons and text labels
  withIcons,

  /// Tab bar with icons only (no text)
  iconOnly,

  /// Elevated tab bar with shadow
  elevated,

  /// Rounded tab bar with custom indicator
  rounded,
}
