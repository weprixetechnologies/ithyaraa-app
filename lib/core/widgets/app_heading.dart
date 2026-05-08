import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// Reusable heading widget.
///
/// - Uses Montserrat (via `AppTextStyles.headingMedium`)
/// - Bold and UPPERCASED
/// - Center-aligned by default
class AppHeading extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? padding;

  const AppHeading({
    super.key,
    required this.text,
    this.textAlign = TextAlign.center,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final headingStyle = AppTextStyles.headingMedium.copyWith(
      fontWeight: FontWeight.w800,
      fontSize: 30,
    ); // slightly larger & bolder

    final content = Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: headingStyle,
    );

    Widget result = Center(child: content);

    if (padding != null) {
      result = Padding(padding: padding!, child: result);
    }

    return result;
  }
}
