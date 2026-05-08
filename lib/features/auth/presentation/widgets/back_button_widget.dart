import 'package:flutter/material.dart';

/// Reusable themed back button with border
class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? iconColor;
  final double? size;

  const BackButtonWidget({
    super.key,
    this.onPressed,
    this.borderColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFFE91E63);
    final buttonSize = size ?? 40.0;
    final border = borderColor ?? themeColor;
    final icon = iconColor ?? themeColor;

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: border,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Icon(
              Icons.arrow_back,
              color: icon,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
