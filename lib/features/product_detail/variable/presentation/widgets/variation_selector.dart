import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/variation.dart';
import '../../domain/entities/product_attribute.dart';

/// Variation selector widget
class VariationSelector extends StatelessWidget {
  final List<ProductAttributeEntity> productAttributes;
  final List<VariationEntity> variations;
  final VariationEntity? selectedVariation;
  final Function(VariationEntity) onVariationSelected;

  const VariationSelector({
    super.key,
    required this.productAttributes,
    required this.variations,
    this.selectedVariation,
    required this.onVariationSelected,
  });

  /// Group variations by attribute name
  Map<String, List<String>> _groupVariationsByAttribute() {
    final Map<String, Set<String>> grouped = {};

    for (final variation in variations) {
      for (final attribute in variation.attributes) {
        final attrName = attribute.attributeName;
        final attrValue = attribute.attributeValue;

        if (!grouped.containsKey(attrName)) {
          grouped[attrName] = <String>{};
        }
        grouped[attrName]!.add(attrValue);
      }
    }

    return grouped.map((key, value) => MapEntry(key, value.toList()));
  }

  /// Get variations for a specific attribute value
  List<VariationEntity> _getVariationsForAttributeValue(
    String attributeName,
    String attributeValue,
  ) {
    return variations.where((variation) {
      return variation.attributes.any((attr) =>
          attr.attributeName == attributeName &&
          attr.attributeValue == attributeValue);
    }).toList();
  }

  /// Check if variation is available (in stock)
  bool _isVariationAvailable(VariationEntity variation) {
    return variation.inStock && variation.stockQuantity > 0;
  }

  @override
  Widget build(BuildContext context) {
    if (productAttributes.isEmpty || variations.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupedAttributes = _groupVariationsByAttribute();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: groupedAttributes.entries.map((entry) {
          final attributeName = entry.key;
          final attributeValues = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attribute Name (e.g., "Color", "Size")
                Text(
                  attributeName,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Attribute Value Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: attributeValues.map((value) {
                    final matchingVariations =
                        _getVariationsForAttributeValue(attributeName, value);
                    final isAvailable = matchingVariations
                        .any((v) => _isVariationAvailable(v));
                    final isSelected = selectedVariation?.attributes.any((attr) =>
                            attr.attributeName == attributeName &&
                            attr.attributeValue == value) ??
                        false;

                    // Find first available variation for this value
                    VariationEntity? availableVariation;
                    try {
                      availableVariation = matchingVariations
                          .firstWhere((v) => _isVariationAvailable(v));
                    } catch (e) {
                      // If no available variation, use first one (will be disabled)
                      if (matchingVariations.isNotEmpty) {
                        availableVariation = matchingVariations.first;
                      }
                    }

                    return FilterChip(
                      label: Text(value),
                      selected: isSelected,
                      onSelected: isAvailable && availableVariation != null
                          ? (_) {
                              onVariationSelected(availableVariation!);
                            }
                          : null,
                      selectedColor: const Color(0xFFE91E63).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFFE91E63),
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? const Color(0xFFE91E63)
                            : (isAvailable ? Colors.black87 : Colors.grey),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      disabledColor: Colors.grey.shade200,
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
