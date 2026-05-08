import 'dart:convert';
import '../../domain/entities/custom_input.dart';

class CustomInputModel extends CustomInputEntity {
  const CustomInputModel({
    required super.id,
    required super.label,
    required super.type,
    super.required,
    super.options,
    super.placeholder,
  });

  factory CustomInputModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedOptions;
    if (json['options'] != null) {
      if (json['options'] is List) {
        parsedOptions = (json['options'] as List).map((e) => e.toString()).toList();
      } else if (json['options'] is String) {
        try {
          final decoded = jsonDecode(json['options'] as String) as List;
          parsedOptions = decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
    }

    return CustomInputModel(
      id: json['id']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      required: json['required'] == true || json['required'] == 'true' || json['required'] == 1,
      options: parsedOptions,
      placeholder: json['placeholder']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'required': required,
      if (options != null) 'options': options,
      if (placeholder != null) 'placeholder': placeholder,
    };
  }
}
