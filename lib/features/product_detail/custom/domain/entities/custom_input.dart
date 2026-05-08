class CustomInputEntity {
  final String id;
  final String label;
  final String type; // text, number, select, file, etc.
  final bool required;
  final List<String>? options;
  final String? placeholder;

  const CustomInputEntity({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
    this.placeholder,
  });
}
