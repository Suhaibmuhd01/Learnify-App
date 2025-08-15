import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PodiumWidget extends StatelessWidget {
  final List<Map<String, dynamic>> topThree;

  const PodiumWidget({
    super.key,
    required this.topThree,
  });

  @override
  Widget build(BuildContext context) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 25.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Stack(
        children: [
          // Podium Base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Second Place
                if (topThree.length > 1)
                  Expanded(
                    child: _buildPodiumStep(
                      rank: 2,
                      height: 12.h,
                      color: const Color(0xFFC0C0C0),
                    ),
                  ),
                // First Place
                if (topThree.isNotEmpty)
                  Expanded(
                    child: _buildPodiumStep(
                      rank: 1,
                      height: 16.h,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                // Third Place
                if (topThree.length > 2)
                  Expanded(
                    child: _buildPodiumStep(
                      rank: 3,
                      height: 8.h,
                      color: const Color(0xFFCD7F32),
                    ),
                  ),
              ],
            ),
          ),
          // User Avatars and Info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Second Place User
                if (topThree.length > 1)
                  Expanded(
                    child: _buildPodiumUser(topThree[1], 2),
                  ),
                // First Place User
                if (topThree.isNotEmpty)
                  Expanded(
                    child: _buildPodiumUser(topThree[0], 1),
                  ),
                // Third Place User
                if (topThree.length > 2)
                  Expanded(
                    child: _buildPodiumUser(topThree[2], 3),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStep({
    required int rank,
    required double height,
    required Color color,
  }) {
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(2.w)),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumUser(Map<String, dynamic> user, int rank) {
    final avatarSize = rank == 1 ? 18.w : 15.w;
    final crownSize = rank == 1 ? 8.w : 6.w;

    return Column(
      children: [
        // Crown for first place
        if (rank == 1) ...[
          CustomIconWidget(
            iconName: 'emoji_events',
            color: const Color(0xFFFFD700),
            size: crownSize,
          ),
          SizedBox(height: 1.h),
        ],
        // User Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRankColor(rank),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _getRankColor(rank).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: CustomImageWidget(
              imageUrl: user["avatar"] as String,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        // Username
        Text(
          user["username"] as String,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        // Points
        Text(
          '${(user["points"] as int).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} pts',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: _getRankColor(rank),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(
            height: rank == 1
                ? 2.h
                : rank == 2
                    ? 6.h
                    : 10.h),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }
}
