import '../../domain/entities/dress_type.dart';

class DressTypeModel extends DressTypeEntity {
  const DressTypeModel({
    required super.label,
    required super.price,
  });

  factory DressTypeModel.fromJson(Map<String, dynamic> json) {
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return DressTypeModel(
      label: json['label']?.toString() ?? '',
      price: parsePrice(json['price']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'price': price,
    };
  }
}
