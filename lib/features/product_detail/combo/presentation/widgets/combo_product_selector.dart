import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/combo_product.dart';
import '../../../variable/domain/entities/variation.dart';
import '../../../variable/presentation/widgets/color_option.dart';
import '../../../variable/presentation/widgets/box_option.dart';

/// Combo product selector widget for selecting variations per product
class ComboProductSelector extends StatelessWidget {
  final ComboProductEntity product;
  final VariationEntity? selectedVariation;
  final Map<String, String> selectedAttributes;
  final Function(VariationEntity?, Map<String, String>) onVariationChanged;

  const ComboProductSelector({
    super.key,
    required this.product,
    this.selectedVariation,
    this.selectedAttributes = const {},
    required this.onVariationChanged,
  });

  /// Get all unique attribute names from variations
  List<String> _getAttributeNames() {
    final Set<String> names = {};
    for (final variation in product.variations) {
      for (final attr in variation.attributes) {
        names.add(attr.attributeName);
      }
    }
    return names.toList();
  }

  /// Get all values for a specific attribute from variations
  List<String> _getAttributeValues(String attributeName) {
    final Set<String> values = {};
    for (final variation in product.variations) {
      for (final attr in variation.attributes) {
        if (attr.attributeName == attributeName) {
          values.add(attr.attributeValue);
        }
      }
    }
    return values.toList();
  }

  /// Get selected attributes map (from prop or selected variation)
  Map<String, String> _getSelectedAttributes() {
    if (selectedAttributes.isNotEmpty) {
      return selectedAttributes;
    }
    final Map<String, String> selected = {};
    final variation = selectedVariation;
    if (variation != null) {
      for (final attr in variation.attributes) {
        selected[attr.attributeName] = attr.attributeValue;
      }
    }
    return selected;
  }

  /// Filter variations that match the selected attributes
  List<VariationEntity> _getMatchingVariations(
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return product.variations;

    return product.variations.where((variation) {
      for (final entry in selectedAttributes.entries) {
        final hasMatchingAttr = variation.attributes.any(
          (attr) =>
              attr.attributeName == entry.key &&
              attr.attributeValue == entry.value,
        );
        if (!hasMatchingAttr) return false;
      }
      return true;
    }).toList();
  }

  /// Check if an attribute value is available given current selections
  bool _isAttributeValueAvailable(
    String attributeName,
    String attributeValue,
    Map<String, String> selectedAttributes,
  ) {
    final testSelection = Map<String, String>.from(selectedAttributes);
    testSelection[attributeName] = attributeValue;
    final matchingVariations = _getMatchingVariations(testSelection);
    return matchingVariations.isNotEmpty;
  }

  /// Get the variation that matches selected attributes (website behavior)
  /// Rules:
  /// 1. Filter variations matching all selected attributes
  /// 2. Only return if stock > 0
  /// 3. Return first matching variation
  /// 4. Allow partial selection (don't require all attributes)
  VariationEntity? _getCompleteVariation(
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return null;

    final matchingVariations = _getMatchingVariations(selectedAttributes);
    if (matchingVariations.isEmpty) {
      return null;
    }

    // Find first variation with stock > 0 (website behavior)
    for (final variation in matchingVariations) {
      if (variation.stockQuantity > 0) {
        return variation;
      }
    }

    // All matching variations are out of stock - return null (silent failure)
    return null;
  }

  /// Check if attribute name is Color (case-insensitive)
  bool _isColorAttribute(String attributeName) {
    return attributeName.toLowerCase() == 'color' ||
        attributeName.toLowerCase() == 'colour';
  }

  @override
  Widget build(BuildContext context) {
    if (product.variations.isEmpty) {
      return const SizedBox.shrink();
    }

    final attributeNames = _getAttributeNames();
    final selectedAttributes = _getSelectedAttributes();

    // Determine stock status
    final variation = selectedVariation;
    final isInStock = variation != null
        ? (variation.inStock && variation.stockQuantity > 0)
        : product.variations.any((v) => v.inStock && v.stockQuantity > 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: AppTextStyles.cardTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Stock status
          Row(
            children: [
              Text(
                'Options:',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isInStock ? 'In Stock' : 'Out of Stock',
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isInStock
                      ? Colors.green.shade600
                      : Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Attribute selectors
          ...attributeNames.map((attributeName) {
            final attributeValues = _getAttributeValues(attributeName);
            final selectedValue = selectedAttributes[attributeName];
            final isColor = _isColorAttribute(attributeName);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attribute title on the left
                  SizedBox(
                    width: 80,
                    child: Text(
                      attributeName,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Options on the right
                  Expanded(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      children: attributeValues.map((value) {
                        final isSelected = selectedValue == value;
                        final isAvailable = _isAttributeValueAvailable(
                          attributeName,
                          value,
                          selectedAttributes,
                        );

                        void handleSelection() {
                          final currentSelected = _getSelectedAttributes();
                          final newSelection = Map<String, String>.from(
                            currentSelected,
                          );
                          if (isSelected) {
                            newSelection.remove(attributeName);
                          } else {
                            newSelection[attributeName] = value;
                          }

                          final completeVariation = _getCompleteVariation(
                            newSelection,
                          );

                          onVariationChanged(completeVariation, newSelection);
                        }

                        return isColor
                            ? ColorOption(
                                colorName: value,
                                isSelected: isSelected,
                                isAvailable: isAvailable,
                                onTap: handleSelection,
                              )
                            : BoxOption(
                                label: value,
                                isSelected: isSelected,
                                isAvailable: isAvailable,
                                onTap: handleSelection,
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
