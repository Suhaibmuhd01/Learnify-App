import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizTimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback onTimeUp;

  const QuizTimerWidget({
    Key? key,
    required this.duration,
    required this.onTimeUp,
  }) : super(key: key);

  @override
  State<QuizTimerWidget> createState() => _QuizTimerWidgetState();
}

class _QuizTimerWidgetState extends State<QuizTimerWidget> {
  late Timer _timer;
  late Duration _remainingTime;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = _remainingTime - const Duration(seconds: 1);
          } else {
            _isTimeUp = true;
            _timer.cancel();
            widget.onTimeUp();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isLowTime = _remainingTime.inMinutes < 2;
    final timeString = _formatTime(_remainingTime);

    return Container(
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
      decoration: BoxDecoration(
        color: _isTimeUp
            ? Colors.red.shade50
            : isLowTime
                ? Colors.orange.shade50
                : Colors.blue.shade50,
        border: Border.all(
          color: _isTimeUp
              ? Colors.red
              : isLowTime
                  ? Colors.orange
                  : Colors.blue,
        ),
        borderRadius: BorderRadius.circular(1.5.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 4.w,
            color: _isTimeUp
                ? Colors.red
                : isLowTime
                    ? Colors.orange
                    : Colors.blue,
          ),
          SizedBox(width: 1.w),
          Text(
            timeString,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: _isTimeUp
                  ? Colors.red
                  : isLowTime
                      ? Colors.orange
                      : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
