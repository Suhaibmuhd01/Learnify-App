import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();

  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username ?? email.split('@')[0],
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  // Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.google);
    } catch (error) {
      throw Exception('Google sign-in failed: $error');
    }
  }

  // Sign in with Apple OAuth
  Future<bool> signInWithApple() async {
    try {
      return await _client.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (error) {
      throw Exception('Apple sign-in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
  }) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (username != null) updates['username'] = username;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isNotEmpty) {
        updates['updated_at'] = DateTime.now().toIso8601String();

        await _client
            .from('user_profiles')
            .update(updates)
            .eq('id', currentUser!.id);
      }
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user achievements
  Future<List<dynamic>> getUserAchievements() async {
    if (!isAuthenticated) return [];

    try {
      final response = await _client
          .from('user_achievements')
          .select('*, achievements(*)')
          .eq('user_id', currentUser!.id)
          .order('earned_at', ascending: false);
      return response;
    } catch (error) {
      throw Exception('Failed to get achievements: $error');
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    if (!isAuthenticated) return {};

    try {
      final profile = await getUserProfile();
      if (profile == null) return {};

      final attemptsCount = await _client
          .from('user_quiz_attempts')
          .select()
          .eq('user_id', currentUser!.id)
          .eq('is_completed', true)
          .count();

      final topicsProgress = await _client
          .from('user_topic_progress')
          .select()
          .eq('user_id', currentUser!.id)
          .count();

      return {
        'total_points': profile['total_points'] ?? 0,
        'level': profile['level_number'] ?? 1,
        'xp_points': profile['xp_points'] ?? 0,
        'current_streak': profile['current_streak'] ?? 0,
        'longest_streak': profile['longest_streak'] ?? 0,
        'quizzes_completed': attemptsCount.count ?? 0,
        'topics_in_progress': topicsProgress.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }
}
