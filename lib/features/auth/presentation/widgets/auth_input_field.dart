import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Modern input field with dynamic label/hint behavior
///
/// Behavior:
/// - Empty + Unfocused: Shows placeholder (hintText)
/// - Focused: Shows label above input
/// - Typing: Shows label above input
/// - Cleared + Unfocused: Shows placeholder (hintText)
///
/// Performance: Only rebuilds InputDecoration, not entire form
class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late FocusNode _focusNode;
  late ValueNotifier<bool> _showLabel;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _showLabel = ValueNotifier<bool>(false);

    // Listen to focus changes
    _focusNode.addListener(_onFocusChange);

    // Listen to text changes
    widget.controller.addListener(_onTextChange);

    // Initialize label state based on current text
    _updateLabelVisibility();
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    _showLabel.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    _updateLabelVisibility();
  }

  void _onTextChange() {
    _updateLabelVisibility();
  }

  void _updateLabelVisibility() {
    final isFocused = _focusNode.hasFocus;
    final hasText = widget.controller.text.isNotEmpty;

    // Show label when focused OR when typing
    final shouldShowLabel = isFocused || hasText;

    if (_showLabel.value != shouldShowLabel) {
      _showLabel.value = shouldShowLabel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showLabel,
      builder: (context, showLabel, child) {
        return TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            // Show label when focused or typing, hide when empty and unfocused
            labelText: showLabel ? widget.label : null,
            // Show hint when empty and unfocused, hide when focused or typing
            hintText: showLabel ? null : widget.hintText,
            labelStyle: AppTextStyles.label.copyWith(fontSize: 14),
            hintStyle: AppTextStyles.inputHint,
            // Use auto to show label above when labelText is set and field is focused/has text
            // This works with our manual labelText/hintText toggling
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            suffixIcon: widget.suffixIcon,
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        );
      },
    );
  }
}
