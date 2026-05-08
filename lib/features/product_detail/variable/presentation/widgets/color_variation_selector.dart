import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/variation.dart';
import '../../domain/entities/product_attribute.dart';

/// Color variation selector with circular swatches
class ColorVariationSelector extends StatelessWidget {
  final List<ProductAttributeEntity> productAttributes;
  final List<VariationEntity> variations;
  final VariationEntity? selectedVariation;
  final Function(VariationEntity) onVariationSelected;

  const ColorVariationSelector({
    super.key,
    required this.productAttributes,
    required this.variations,
    this.selectedVariation,
    required this.onVariationSelected,
  });

  /// Get color name from attribute value
  String _getColorName(String value) {
    // Map common color values to display names
    final colorMap = {
      'light blue': 'Light Blue',
      'dark blue': 'Dark Blue',
      'black': 'Black',
      'gray': 'Gray',
      'grey': 'Gray',
      'white': 'White',
      'red': 'Red',
      'green': 'Green',
      'yellow': 'Yellow',
      'orange': 'Orange',
      'purple': 'Purple',
      'pink': 'Pink',
    };

    final lowerValue = value.toLowerCase();
    for (final entry in colorMap.entries) {
      if (lowerValue.contains(entry.key)) {
        return entry.value;
      }
    }
    // Capitalize first letter if no match
    return value.isEmpty
        ? value
        : value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  /// Get color from attribute value
  Color _getColorFromName(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue.contains('light blue') || lowerValue.contains('lightblue')) {
      return Colors.lightBlue.shade300;
    } else if (lowerValue.contains('dark blue') ||
        lowerValue.contains('darkblue')) {
      return Colors.blue.shade900;
    } else if (lowerValue.contains('black')) {
      return Colors.black;
    } else if (lowerValue.contains('gray') || lowerValue.contains('grey')) {
      return Colors.grey.shade600;
    } else if (lowerValue.contains('white')) {
      return Colors.white;
    } else if (lowerValue.contains('red')) {
      return Colors.red;
    } else if (lowerValue.contains('green')) {
      return Colors.green;
    } else if (lowerValue.contains('yellow')) {
      return Colors.yellow;
    } else if (lowerValue.contains('orange')) {
      return Colors.orange;
    } else if (lowerValue.contains('purple')) {
      return Colors.purple;
    } else if (lowerValue.contains('pink')) {
      return Colors.pink;
    }
    // Default to gray if color not recognized
    return Colors.grey.shade400;
  }

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
      return variation.attributes.any(
        (attr) =>
            attr.attributeName == attributeName &&
            attr.attributeValue == attributeValue,
      );
    }).toList();
  }

  /// Check if variation is available (in stock)
  bool _isVariationAvailable(VariationEntity variation) {
    return variation.inStock && variation.stockQuantity > 0;
  }

  /// Get selected attribute value for display
  String? _getSelectedValue(String attributeName) {
    if (selectedVariation == null) return null;
    for (final attr in selectedVariation!.attributes) {
      if (attr.attributeName == attributeName) {
        return attr.attributeValue;
      }
    }
    return null;
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
          final selectedValue = _getSelectedValue(attributeName);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attribute Name with current selection
                Text(
                  '$attributeName: ${selectedValue != null ? _getColorName(selectedValue) : (attributeValues.isNotEmpty ? _getColorName(attributeValues.first) : "")}',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Color swatches
                Row(
                  children: attributeValues.map((value) {
                    final matchingVariations = _getVariationsForAttributeValue(
                      attributeName,
                      value,
                    );
                    final isAvailable = matchingVariations.any(
                      (v) => _isVariationAvailable(v),
                    );
                    final isSelected = selectedValue == value;

                    // Find first available variation for this value
                    VariationEntity? availableVariation;
                    try {
                      availableVariation = matchingVariations.firstWhere(
                        (v) => _isVariationAvailable(v),
                      );
                    } catch (e) {
                      if (matchingVariations.isNotEmpty) {
                        availableVariation = matchingVariations.first;
                      }
                    }

                    return GestureDetector(
                      onTap: isAvailable && availableVariation != null
                          ? () => onVariationSelected(availableVariation!)
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Color swatch
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getColorFromName(value),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                            ),
                            // Disabled overlay
                            if (!isAvailable)
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300.withValues(
                                    alpha: 0.6,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
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
