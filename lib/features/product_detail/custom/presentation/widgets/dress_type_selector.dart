import 'package:flutter/material.dart';
import '../../domain/entities/dress_type.dart';

class DressTypeSelector extends StatelessWidget {
  final List<DressTypeEntity> dressTypes;
  final DressTypeEntity? selectedDressType;
  final Function(DressTypeEntity) onSelect;
  final bool showErrors;

  const DressTypeSelector({
    super.key,
    required this.dressTypes,
    required this.selectedDressType,
    required this.onSelect,
    this.showErrors = false,
  });

  @override
  Widget build(BuildContext context) {
    if (dressTypes.isEmpty) return const SizedBox.shrink();

    final isMissing = showErrors && selectedDressType == null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                  color: isMissing ? Colors.red : const Color(0xFFFFD232),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Select Dress Type',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isMissing ? Colors.red.shade700 : Colors.grey.shade900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                ' *',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              'Pricing varies by garment type',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
          if (isMissing) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 11),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 12, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Please select a dress type to continue',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dressTypes.map((dt) => _buildChip(dt, isMissing)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(DressTypeEntity dt, bool isMissing) {
    final isSelected = selectedDressType?.label == dt.label;

    return GestureDetector(
      onTap: () => onSelect(dt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD232)
                : isMissing
                    ? Colors.red.shade300
                    : Colors.grey.shade300,
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD232).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD232),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 10, color: Colors.black),
              ),
              const SizedBox(width: 6),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  dt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.amber.shade900 : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${dt.price % 1 == 0 ? dt.price.toInt() : dt.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? const Color(0xFFD97706) : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
