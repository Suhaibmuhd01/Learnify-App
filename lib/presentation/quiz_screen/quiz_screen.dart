import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../services/quiz_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/quiz_progress_widget.dart';
import './widgets/quiz_question_widget.dart';
import './widgets/quiz_timer_widget.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizService _quizService = QuizService.instance;

  Map<String, dynamic>? _quizData;
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _score = 0;
  DateTime? _startTime;
  int _timeLimit = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuiz();
    });
  }

  void _loadQuiz() async {
    final quizId = ModalRoute.of(context)!.settings.arguments as String?;
    if (quizId == null) {
      Navigator.pop(context);
      return;
    }

    try {
      final quizData = await _quizService.getQuizWithQuestions(quizId);
      if (mounted && quizData != null) {
        setState(() {
          _quizData = quizData;
          _questions = quizData['questions'] ?? [];
          _timeLimit = quizData['quiz']['time_limit_minutes'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load quiz: $error')));
      }
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _finishQuiz() async {
    if (_isSubmitting || _quizCompleted) return;

    setState(() {
      _isSubmitting = true;
      _quizCompleted = true;
    });

    try {
      // Calculate score
      int correctAnswers = 0;
      for (int i = 0; i < _questions.length; i++) {
        final question = _questions[i];
        final userAnswer = _userAnswers[i];
        if (userAnswer == question['correct_answer']) {
          correctAnswers++;
          _score += (question['points_value'] ?? 10) as int;
        }
      }

      final timeTaken = DateTime.now().difference(_startTime!).inSeconds;

      // Submit quiz attempt
      await _quizService.submitQuizAttempt(
          quizId: _quizData!['quiz']['id'],
          score: _score,
          totalQuestions: _questions.length,
          correctAnswers: correctAnswers,
          timeTakenSeconds: timeTaken,
          isCompleted: true);

      // Navigate to results screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/quiz-results', arguments: {
          'score': _score,
          'correct_answers': correctAnswers,
          'total_questions': _questions.length,
          'time_taken': timeTaken,
          'quiz_title': _quizData!['quiz']['title'],
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit quiz: $error')));
      }
    }
  }

  void _onTimeUp() {
    if (!_quizCompleted) {
      _finishQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
          appBar: CustomAppBar(title: 'Loading Quiz...'),
          body: const Center(child: CircularProgressIndicator()));
    }

    if (_questions.isEmpty) {
      return Scaffold(
          appBar: CustomAppBar(title: 'Quiz'),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                SizedBox(height: 2.h),
                Text('No questions available',
                    style: GoogleFonts.inter(
                        fontSize: 16.sp, color: Colors.grey[600])),
                SizedBox(height: 2.h),
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back')),
              ])));
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
        appBar: CustomAppBar(
            title: _quizData?['quiz']['title'] ?? 'Quiz',
            actions: [
              if (_timeLimit > 0)
                QuizTimerWidget(
                    duration: Duration(minutes: _timeLimit),
                    onTimeUp: _onTimeUp),
            ]),
        body: Column(children: [
          // Progress indicator
          QuizProgressWidget(
              progress: progress,
              currentQuestion: _currentQuestionIndex + 1,
              totalQuestions: _questions.length),

          // Question content
          Expanded(
              child: QuizQuestionWidget(
                  question: currentQuestion,
                  selectedAnswer: _userAnswers[_currentQuestionIndex],
                  onAnswerSelected: _selectAnswer)),

          // Navigation buttons
          Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [
                BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2)),
              ]),
              child: Row(children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                      child: OutlinedButton(
                          onPressed: _previousQuestion,
                          child: const Text('Previous'))),
                if (_currentQuestionIndex > 0) SizedBox(width: 4.w),
                Expanded(
                    child: ElevatedButton(
                        onPressed: _userAnswers
                                .containsKey(_currentQuestionIndex)
                            ? (_currentQuestionIndex == _questions.length - 1
                                ? (_isSubmitting ? null : _finishQuiz)
                                : _nextQuestion)
                            : null,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                                _currentQuestionIndex == _questions.length - 1
                                    ? 'Finish Quiz'
                                    : 'Next'))),
              ])),
        ]));
  }
}