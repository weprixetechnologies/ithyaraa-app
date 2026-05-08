import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/custom_input.dart';

class CustomInputsForm extends StatelessWidget {
  final List<CustomInputEntity> inputs;
  final Map<String, dynamic> values;
  final Function(String, dynamic) onChanged;
  final bool showErrors;

  const CustomInputsForm({
    super.key,
    required this.inputs,
    required this.values,
    required this.onChanged,
    this.showErrors = false,
  });

  @override
  Widget build(BuildContext context) {
    if (inputs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 3,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD232),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Your Customisations',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              'Fill in the details for your made-to-order piece',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          ...inputs.map((input) => _buildInputField(input)),
        ],
      ),
    );
  }

  Widget _buildInputField(CustomInputEntity input) {
    final value = values[input.id];
    final bool isMissing = showErrors &&
        input.required &&
        (value == null || (value is String && value.trim().isEmpty));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                input.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isMissing ? Colors.red.shade700 : Colors.grey.shade800,
                  letterSpacing: 0.1,
                ),
              ),
              if (input.required)
                Text(
                  ' *',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (input.type == 'select')
            _buildDropdown(input, value, isMissing)
          else
            _buildTextField(input, value, isMissing),
          if (isMissing)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 12, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'This field is required',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(CustomInputEntity input, dynamic value, bool isMissing) {
    final options = input.options ?? [];
    final selectedValue = (value != null && options.contains(value.toString())) ? value.toString() : null;

    return Container(
      decoration: BoxDecoration(
        color: isMissing ? Colors.red.shade50 : Colors.white,
        border: Border.all(
          color: isMissing ? Colors.red.shade400 : Colors.grey.shade300,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedValue,
          hint: Text(
            input.placeholder ?? 'Select an option',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade500),
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(opt, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) => onChanged(input.id, val),
          style: TextStyle(color: Colors.grey.shade900, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTextField(CustomInputEntity input, dynamic value, bool isMissing) {
    TextInputType keyboardType = TextInputType.text;
    List<TextInputFormatter> formatters = [];
    if (input.type == 'number') {
      keyboardType = TextInputType.number;
      formatters = [FilteringTextInputFormatter.digitsOnly];
    }
    if (input.type == 'tel') keyboardType = TextInputType.phone;
    if (input.type == 'email') keyboardType = TextInputType.emailAddress;

    final isTextarea = input.type == 'textarea';

    return TextFormField(
      initialValue: value?.toString() ?? '',
      keyboardType: isTextarea ? TextInputType.multiline : keyboardType,
      textInputAction: isTextarea ? TextInputAction.newline : TextInputAction.next,
      inputFormatters: formatters,
      onChanged: (val) => onChanged(input.id, val),
      maxLines: isTextarea ? 4 : 1,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: input.placeholder,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: isMissing ? Colors.red.shade50 : Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: isTextarea ? 14 : 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isMissing ? Colors.red.shade400 : Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isMissing ? Colors.red.shade400 : Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isMissing ? Colors.red.shade500 : const Color(0xFFFFD232),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
