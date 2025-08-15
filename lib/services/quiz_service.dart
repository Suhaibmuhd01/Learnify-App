import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class QuizService {
  static QuizService? _instance;
  static QuizService get instance => _instance ??= QuizService._();

  QuizService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all published quizzes
  Future<List<dynamic>> getPublishedQuizzes() async {
    try {
      final response = await _client
          .from('quizzes')
          .select('*, topics(name, icon_name, color_code)')
          .eq('status', 'published')
          .order('created_at', ascending: false);
      return response;
    } catch (error) {
      throw Exception('Failed to get quizzes: $error');
    }
  }

  // Get quizzes by topic
  Future<List<dynamic>> getQuizzesByTopic(String topicId) async {
    try {
      final response = await _client
          .from('quizzes')
          .select('*, topics(name, icon_name, color_code)')
          .eq('topic_id', topicId)
          .eq('status', 'published')
          .order('created_at', ascending: false);
      return response;
    } catch (error) {
      throw Exception('Failed to get quizzes by topic: $error');
    }
  }

  // Get quiz with questions and options
  Future<Map<String, dynamic>?> getQuizWithQuestions(String quizId) async {
    try {
      final quiz = await _client
          .from('quizzes')
          .select('*, topics(name, icon_name, color_code)')
          .eq('id', quizId)
          .single();

      final questions = await _client
          .from('questions')
          .select('*, question_options(*)')
          .eq('quiz_id', quizId)
          .order('sort_order', ascending: true);

      return {
        'quiz': quiz,
        'questions': questions,
      };
    } catch (error) {
      throw Exception('Failed to get quiz details: $error');
    }
  }

  // Submit quiz attempt
  Future<Map<String, dynamic>> submitQuizAttempt({
    required String quizId,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required int timeTakenSeconds,
    required bool isCompleted,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('user_quiz_attempts')
          .insert({
            'user_id': user.id,
            'quiz_id': quizId,
            'score': score,
            'total_questions': totalQuestions,
            'correct_answers': correctAnswers,
            'time_taken_seconds': timeTakenSeconds,
            'is_completed': isCompleted,
          })
          .select()
          .single();

      // Update user points and XP
      if (isCompleted && score > 0) {
        await _updateUserProgress(score);
        await _updateTopicProgress(quizId, score);
        await _checkAchievements(user.id);
      }

      return response;
    } catch (error) {
      throw Exception('Failed to submit quiz attempt: $error');
    }
  }

  // Get user's quiz attempts
  Future<List<dynamic>> getUserQuizAttempts() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('user_quiz_attempts')
          .select('*, quizzes(title, topics(name))')
          .eq('user_id', user.id)
          .order('completed_at', ascending: false)
          .limit(20);
      return response;
    } catch (error) {
      throw Exception('Failed to get quiz attempts: $error');
    }
  }

  // Get daily challenge
  Future<Map<String, dynamic>?> getDailyChallenge() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _client
          .from('daily_challenges')
          .select('*, quizzes(*, topics(name, icon_name, color_code))')
          .eq('challenge_date', today)
          .eq('is_active', true)
          .maybeSingle();
      return response;
    } catch (error) {
      throw Exception('Failed to get daily challenge: $error');
    }
  }

  // Private helper methods
  Future<void> _updateUserProgress(int points) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await _client
          .from('user_profiles')
          .select('total_points, xp_points, current_streak')
          .eq('id', user.id)
          .single();

      final newTotalPoints = (profile['total_points'] ?? 0) + points;
      final newXpPoints = (profile['xp_points'] ?? 0) + points;
      final newStreak = (profile['current_streak'] ?? 0) + 1;

      await _client.from('user_profiles').update({
        'total_points': newTotalPoints,
        'xp_points': newXpPoints,
        'current_streak': newStreak,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (error) {
      // Silent fail for stats update
      print('Failed to update user progress: $error');
    }
  }

  Future<void> _updateTopicProgress(String quizId, int points) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final quiz = await _client
          .from('quizzes')
          .select('topic_id')
          .eq('id', quizId)
          .single();

      if (quiz['topic_id'] != null) {
        final existing = await _client
            .from('user_topic_progress')
            .select('quizzes_completed, total_points')
            .eq('user_id', user.id)
            .eq('topic_id', quiz['topic_id'])
            .maybeSingle();

        if (existing != null) {
          await _client
              .from('user_topic_progress')
              .update({
                'quizzes_completed': (existing['quizzes_completed'] ?? 0) + 1,
                'total_points': (existing['total_points'] ?? 0) + points,
                'last_activity': DateTime.now().toIso8601String(),
              })
              .eq('user_id', user.id)
              .eq('topic_id', quiz['topic_id']);
        } else {
          await _client.from('user_topic_progress').insert({
            'user_id': user.id,
            'topic_id': quiz['topic_id'],
            'quizzes_completed': 1,
            'total_points': points,
          });
        }
      }
    } catch (error) {
      // Silent fail for topic progress update
      print('Failed to update topic progress: $error');
    }
  }

  Future<void> _checkAchievements(String userId) async {
    try {
      // Check for "First Steps" achievement
      final attemptsCount = await _client
          .from('user_quiz_attempts')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true)
          .count();

      if (attemptsCount.count == 1) {
        final firstStepsAchievement = await _client
            .from('achievements')
            .select('id')
            .eq('name', 'First Steps')
            .maybeSingle();

        if (firstStepsAchievement != null) {
          await _client.from('user_achievements').insert({
            'user_id': userId,
            'achievement_id': firstStepsAchievement['id'],
          });
        }
      }
    } catch (error) {
      // Silent fail for achievement checking
      print('Failed to check achievements: $error');
    }
  }
}
