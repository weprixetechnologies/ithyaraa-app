import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/variation.dart';

/// Variation selector with proper combination logic
/// Variation availability is dynamically derived from valid combinations, not assumed.
class VariationSelectorV2 extends StatelessWidget {
  final List<VariationEntity> variations;
  final VariationEntity? selectedVariation;
  final Map<String, String> selectedAttributes;
  final Function(VariationEntity?, Map<String, String>) onVariationChanged;

  const VariationSelectorV2({
    super.key,
    required this.variations,
    this.selectedVariation,
    this.selectedAttributes = const {},
    required this.onVariationChanged,
  });

  /// Get all unique attribute names from variations
  List<String> _getAttributeNames() {
    final Set<String> names = {};
    for (final variation in variations) {
      for (final attr in variation.attributes) {
        names.add(attr.attributeName);
      }
    }
    return names.toList();
  }

  /// Get all values for a specific attribute from variations
  List<String> _getAttributeValues(String attributeName) {
    final Set<String> values = {};
    for (final variation in variations) {
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
    // Use provided selectedAttributes if available, otherwise extract from variation
    if (selectedAttributes.isNotEmpty) {
      return selectedAttributes;
    }
    final Map<String, String> selected = {};
    if (selectedVariation != null) {
      for (final attr in selectedVariation!.attributes) {
        selected[attr.attributeName] = attr.attributeValue;
      }
    }
    return selected;
  }

  /// Filter variations that match the selected attributes
  List<VariationEntity> _getMatchingVariations(
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return variations;

    return variations.where((variation) {
      // Check if variation matches ALL selected attributes
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
    // Create a test selection with this attribute value
    final testSelection = Map<String, String>.from(selectedAttributes);
    testSelection[attributeName] = attributeValue;

    // Check if any variation matches this test selection
    final matchingVariations = _getMatchingVariations(testSelection);
    return matchingVariations.isNotEmpty;
  }

  /// Get the variation that matches all selected attributes (if complete)
  /// Only returns a variation when ALL attributes are selected and a matching variation exists
  VariationEntity? _getCompleteVariation(
    Map<String, String> selectedAttributes,
  ) {
    if (selectedAttributes.isEmpty) return null;

    final allAttributeNames = _getAttributeNames();

    // Only return a variation if we have selected ALL attributes
    if (selectedAttributes.length != allAttributeNames.length) {
      return null;
    }

    final matchingVariations = _getMatchingVariations(selectedAttributes);

    if (matchingVariations.isEmpty) {
      return null;
    }

    // Find variation that has ALL selected attributes matching exactly
    for (final variation in matchingVariations) {
      // Check if variation has all selected attributes
      bool allMatch = true;

      // Variation must have at least as many attributes as selected
      if (variation.attributes.length < selectedAttributes.length) {
        continue;
      }

      // Check each selected attribute
      for (final entry in selectedAttributes.entries) {
        final hasMatch = variation.attributes.any(
          (attr) =>
              attr.attributeName == entry.key &&
              attr.attributeValue == entry.value,
        );
        if (!hasMatch) {
          allMatch = false;
          break;
        }
      }

      if (allMatch) {
        // Prefer in-stock variations
        if (variation.inStock && variation.stockQuantity > 0) {
          return variation;
        }
      }
    }

    // If no in-stock variation found, return first matching (might be out of stock)
    // This ensures price/stock still update even if out of stock
    return matchingVariations.first;
  }

  /// Check if attribute name is Color (case-insensitive)
  bool _isColorAttribute(String attributeName) {
    return attributeName.toLowerCase() == 'color' ||
        attributeName.toLowerCase() == 'colour';
  }

  @override
  Widget build(BuildContext context) {
    if (variations.isEmpty) {
      return const SizedBox.shrink();
    }

    final attributeNames = _getAttributeNames();
    final selectedAttributes = _getSelectedAttributes();

    // Determine stock status
    final isInStock = selectedVariation != null
        ? (selectedVariation!.inStock && selectedVariation!.stockQuantity > 0)
        : variations.any((v) => v.inStock && v.stockQuantity > 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider above section heading
          Container(
            height: 3,
            width: double.infinity,
            color: Colors.grey.shade100,
          ),
          // Section heading: "Options Tailored For You :" with stock status
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 16),
            child: Row(
              children: [
                Text(
                  'Options Tailored For You :',
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
          ),

          // Grid-like layout for attributes (50% each, last one 100% if odd)
          ..._buildAttributeGrid(context, attributeNames, selectedAttributes),
        ],
      ),
    );
  }

  /// Builds the attribute selectors in a grid layout
  List<Widget> _buildAttributeGrid(
    BuildContext context,
    List<String> attributeNames,
    Map<String, String> selectedAttributes,
  ) {
    final List<Widget> rows = [];
    
    for (int i = 0; i < attributeNames.length; i += 2) {
      if (i + 1 < attributeNames.length) {
        // Two attributes in a row (50% width each)
        rows.add(
          Row(
            children: [
              Expanded(
                child: _buildAttributeSelector(
                  context,
                  attributeNames[i],
                  _getAttributeValues(attributeNames[i]),
                  selectedAttributes[attributeNames[i]],
                  selectedAttributes,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttributeSelector(
                  context,
                  attributeNames[i + 1],
                  _getAttributeValues(attributeNames[i + 1]),
                  selectedAttributes[attributeNames[i + 1]],
                  selectedAttributes,
                ),
              ),
            ],
          ),
        );
      } else {
        // Last single attribute (100% width)
        rows.add(
          _buildAttributeSelector(
            context,
            attributeNames[i],
            _getAttributeValues(attributeNames[i]),
            selectedAttributes[attributeNames[i]],
            selectedAttributes,
          ),
        );
      }
      // Add spacing between rows
      if (i + 2 < attributeNames.length || attributeNames.length % 2 == 1 && i < attributeNames.length - 1) {
         rows.add(const SizedBox(height: 12));
      } else if (attributeNames.length > 1) {
         rows.add(const SizedBox(height: 12));
      }
    }
    
    return rows;
  }

  /// Builds a single attribute selector box (Dropdown style)
  Widget _buildAttributeSelector(
    BuildContext context,
    String attributeName,
    List<String> values,
    String? selectedValue,
    Map<String, String> currentSelectedAttributes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showSelectionBottomSheet(
            context,
            attributeName,
            values,
            selectedValue,
            currentSelectedAttributes,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.8),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(0), // Sharp boxes as per image
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: '$attributeName: ',
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: selectedValue ?? 'Select',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Shows a bottom sheet for selecting an attribute value
  void _showSelectionBottomSheet(
    BuildContext context,
    String attributeName,
    List<String> values,
    String? selectedValue,
    Map<String, String> currentSelectedAttributes,
  ) {
    final isColor = _isColorAttribute(attributeName);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select $attributeName',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: values.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final value = values[index];
                    final isSelected = selectedValue == value;
                    final isAvailable = _isAttributeValueAvailable(
                      attributeName,
                      value,
                      currentSelectedAttributes,
                    );

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: isColor 
                        ? Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _parseColor(value),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          )
                        : null,
                      title: Text(
                        value,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isAvailable ? Colors.black : Colors.grey,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.black)
                          : (!isAvailable 
                              ? Text('Out of Stock', 
                                  style: AppTextStyles.caption.copyWith(color: Colors.red)) 
                              : null),
                      onTap: isAvailable
                          ? () {
                              Navigator.pop(context);
                              _handleSelection(attributeName, value);
                            }
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Helper to parse color names to Color objects
  Color _parseColor(String colorName) {
    try {
      // Basic color mapping or hex parsing
      final name = colorName.toLowerCase().trim();
      switch (name) {
        case 'white': return Colors.white;
        case 'black': return Colors.black;
        case 'red': return Colors.red;
        case 'blue': return Colors.blue;
        case 'green': return Colors.green;
        case 'yellow': return Colors.yellow;
        case 'grey':
        case 'gray': return Colors.grey;
        case 'pink': return Colors.pink;
        case 'purple': return Colors.purple;
        case 'orange': return Colors.orange;
        case 'brown': return Colors.brown;
      }
      
      // Try parsing as hex if it looks like one
      if (name.startsWith('#')) {
        final hex = name.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Fallback
    }
    return Colors.transparent;
  }

  /// Shared handler for updating selection
  void _handleSelection(String attributeName, String value) {
    // Get fresh selected attributes
    final currentSelected = _getSelectedAttributes();

    // Update selection
    final newSelection = Map<String, String>.from(currentSelected);
    
    // Check if clicking same one to deselect (optional, usually dropdowns don't deselect)
    if (newSelection[attributeName] == value) {
      // Keep it selected or remove? Let's follow standard dropdown behavior: keep selected.
    } else {
      newSelection[attributeName] = value;
    }

    // Find complete variation if all attributes selected
    final completeVariation = _getCompleteVariation(newSelection);

    // Always pass the new selection map
    onVariationChanged(completeVariation, newSelection);
  }
}
