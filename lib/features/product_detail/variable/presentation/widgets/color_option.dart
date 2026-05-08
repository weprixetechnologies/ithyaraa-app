import 'package:flutter/material.dart';

/// Color option widget - circular swatch
class ColorOption extends StatelessWidget {
  final String colorName;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;

  const ColorOption({
    super.key,
    required this.colorName,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  /// Get color from color name
  Color _getColorFromName(String value) {
    final lowerValue = value.toLowerCase();
    if (lowerValue.contains('light blue') || lowerValue.contains('lightblue')) {
      return Colors.lightBlue.shade300;
    } else if (lowerValue.contains('dark blue') || lowerValue.contains('darkblue')) {
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
    } else if (lowerValue.contains('brown')) {
      return Colors.brown;
    } else if (lowerValue.contains('beige')) {
      return Colors.brown.shade200;
    } else if (lowerValue.contains('navy')) {
      return Colors.blue.shade900;
    }
    // Default to gray if color not recognized
    return Colors.grey.shade400;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Color swatch circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColorFromName(colorName),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Colors.black
                      : Colors.grey.shade300,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
            ),
            // Disabled overlay (only blocks interaction if not available)
            if (!isAvailable)
              IgnorePointer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
