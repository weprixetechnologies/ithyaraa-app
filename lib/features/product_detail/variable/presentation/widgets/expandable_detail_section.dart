import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Expandable detail section item
class ExpandableDetailItem extends StatefulWidget {
  final String title;
  final String? content;

  const ExpandableDetailItem({super.key, required this.title, this.content});

  @override
  State<ExpandableDetailItem> createState() => _ExpandableDetailItemState();
}

class _ExpandableDetailItemState extends State<ExpandableDetailItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.remove : Icons.add,
                    size: 20,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (_isExpanded && widget.content != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  widget.content!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
