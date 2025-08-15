import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class LeaderboardService {
  static LeaderboardService? _instance;
  static LeaderboardService get instance =>
      _instance ??= LeaderboardService._();

  LeaderboardService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get global leaderboard
  Future<List<dynamic>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select(
              'id, full_name, username, avatar_url, total_points, level_number, current_streak')
          .eq('is_active', true)
          .order('total_points', ascending: false)
          .order('level_number', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get global leaderboard: $error');
    }
  }

  // Get topic-specific leaderboard
  Future<List<dynamic>> getTopicLeaderboard(String topicId,
      {int limit = 50}) async {
    try {
      final response = await _client
          .from('user_topic_progress')
          .select(
              'user_id, total_points, mastery_percentage, user_profiles(id, full_name, username, avatar_url, level_number)')
          .eq('topic_id', topicId)
          .order('total_points', ascending: false)
          .order('mastery_percentage', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get topic leaderboard: $error');
    }
  }

  // Get user's rank in global leaderboard
  Future<Map<String, dynamic>> getUserGlobalRank() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final userProfile = await _client
          .from('user_profiles')
          .select('total_points, level_number')
          .eq('id', user.id)
          .single();

      final higherRanked = await _client
          .from('user_profiles')
          .select()
          .gt('total_points', userProfile['total_points'])
          .eq('is_active', true)
          .count();

      final rank = (higherRanked.count ?? 0) + 1;

      return {
        'rank': rank,
        'total_points': userProfile['total_points'],
        'level_number': userProfile['level_number'],
      };
    } catch (error) {
      throw Exception('Failed to get user rank: $error');
    }
  }

  // Get weekly leaderboard (users who scored points this week)
  Future<List<dynamic>> getWeeklyLeaderboard({int limit = 50}) async {
    try {
      final oneWeekAgo =
          DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

      final response = await _client
          .from('user_quiz_attempts')
          .select(
              'user_id, SUM(score) as weekly_score, user_profiles(id, full_name, username, avatar_url, level_number)')
          .gte('completed_at', oneWeekAgo)
          .eq('is_completed', true)
          .order('weekly_score', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get weekly leaderboard: $error');
    }
  }

  // Get streak leaderboard (users with highest current streaks)
  Future<List<dynamic>> getStreakLeaderboard({int limit = 50}) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select(
              'id, full_name, username, avatar_url, current_streak, longest_streak, level_number')
          .eq('is_active', true)
          .gt('current_streak', 0)
          .order('current_streak', ascending: false)
          .order('longest_streak', ascending: false)
          .limit(limit);
      return response;
    } catch (error) {
      throw Exception('Failed to get streak leaderboard: $error');
    }
  }

  // Search users by username
  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select(
              'id, full_name, username, avatar_url, total_points, level_number')
          .or('full_name.ilike.%$query%,username.ilike.%$query%')
          .eq('is_active', true)
          .order('total_points', ascending: false)
          .limit(20);
      return response;
    } catch (error) {
      throw Exception('Failed to search users: $error');
    }
  }

  // Get leaderboard stats
  Future<Map<String, dynamic>> getLeaderboardStats() async {
    try {
      final totalUsers = await _client
          .from('user_profiles')
          .select()
          .eq('is_active', true)
          .count();

      final activeToday = await _client
          .from('user_quiz_attempts')
          .select()
          .gte('completed_at', DateTime.now().toIso8601String().split('T')[0])
          .count();

      final topPlayer = await _client
          .from('user_profiles')
          .select('full_name, total_points')
          .eq('is_active', true)
          .order('total_points', ascending: false)
          .limit(1);

      return {
        'total_users': totalUsers.count ?? 0,
        'active_today': activeToday.count ?? 0,
        'top_player': topPlayer.isNotEmpty ? topPlayer.first : null,
      };
    } catch (error) {
      throw Exception('Failed to get leaderboard stats: $error');
    }
  }
}
