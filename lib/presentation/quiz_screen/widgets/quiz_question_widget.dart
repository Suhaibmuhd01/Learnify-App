import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const QuizQuestionWidget({
    Key? key,
    required this.question,
    this.selectedAnswer,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final questionOptions =
        question['question_options'] as List<dynamic>? ?? [];
    final questionText = question['question_text'] ?? '';
    final questionType = question['type'] ?? 'multiple_choice';

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Text(
              questionText,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Answer options
          if (questionType == 'multiple_choice')
            _buildMultipleChoiceOptions(questionOptions)
          else if (questionType == 'true_false')
            _buildTrueFalseOptions()
          else
            _buildFillInBlankOption(),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions(List<dynamic> options) {
    // Sort options by sort_order
    options
        .sort((a, b) => (a['sort_order'] ?? 0).compareTo(b['sort_order'] ?? 0));

    return Column(
      children: options.map<Widget>((option) {
        final optionText = option['option_text'] ?? '';
        final isSelected = selectedAnswer == optionText;

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          child: InkWell(
            onTap: () => onAnswerSelected(optionText),
            borderRadius: BorderRadius.circular(2.w),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(2.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(26),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade400,
                        width: 2,
                      ),
                      color: isSelected ? Colors.blue : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      optionText,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.blue.shade700
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalseOptions() {
    final trueSelected = selectedAnswer == 'True';
    final falseSelected = selectedAnswer == 'False';

    return Column(
      children: [
        _buildTrueFalseOption('True', trueSelected),
        SizedBox(height: 2.h),
        _buildTrueFalseOption('False', falseSelected),
      ],
    );
  }

  Widget _buildTrueFalseOption(String value, bool isSelected) {
    return InkWell(
      onTap: () => onAnswerSelected(value),
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(2.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.blue.shade700 : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFillInBlankOption() {
    return TextField(
      onChanged: onAnswerSelected,
      decoration: InputDecoration(
        hintText: 'Enter your answer...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2.w),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      style: GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
