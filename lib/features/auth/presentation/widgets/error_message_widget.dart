import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// User-friendly error message display widget
class ErrorMessageWidget extends StatelessWidget {
  final String message;
  final EdgeInsets? padding;

  const ErrorMessageWidget({
    super.key,
    required this.message,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding ?? const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.error.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
