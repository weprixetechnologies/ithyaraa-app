import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/offer_filters.dart';

/// Offer filter page for filtering offers
class OfferFilterPage extends StatefulWidget {
  final OfferFilters? initialFilters;

  const OfferFilterPage({
    super.key,
    this.initialFilters,
  });

  @override
  State<OfferFilterPage> createState() => _OfferFilterPageState();
}

class _OfferFilterPageState extends State<OfferFilterPage> {
  late TextEditingController _offerIDController;
  late TextEditingController _offerNameController;
  late TextEditingController _buyAtController;
  late TextEditingController _buyCountController;
  late TextEditingController _getCountController;
  String? _selectedOfferType;

  // Offer type options
  final List<String> _offerTypes = [
    'buy_x_get_y',
    'percentage',
    'flat',
  ];

  @override
  void initState() {
    super.initState();
    final filters = widget.initialFilters ?? const OfferFilters();
    _offerIDController = TextEditingController(text: filters.offerID ?? '');
    _offerNameController = TextEditingController(text: filters.offerName ?? '');
    _buyAtController = TextEditingController(
      text: filters.buyAt?.toString() ?? '',
    );
    _buyCountController = TextEditingController(
      text: filters.buyCount?.toString() ?? '',
    );
    _getCountController = TextEditingController(
      text: filters.getCount?.toString() ?? '',
    );
    _selectedOfferType = filters.offerType;
  }

  @override
  void dispose() {
    _offerIDController.dispose();
    _offerNameController.dispose();
    _buyAtController.dispose();
    _buyCountController.dispose();
    _getCountController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final filters = OfferFilters(
      offerID: _offerIDController.text.trim().isEmpty
          ? null
          : _offerIDController.text.trim(),
      offerName: _offerNameController.text.trim().isEmpty
          ? null
          : _offerNameController.text.trim(),
      offerType: _selectedOfferType,
      buyAt: _buyAtController.text.trim().isEmpty
          ? null
          : double.tryParse(_buyAtController.text.trim()),
      buyCount: _buyCountController.text.trim().isEmpty
          ? null
          : int.tryParse(_buyCountController.text.trim()),
      getCount: _getCountController.text.trim().isEmpty
          ? null
          : int.tryParse(_getCountController.text.trim()),
    );

    Navigator.of(context).pop(filters);
  }

  void _resetFilters() {
    setState(() {
      _offerIDController.clear();
      _offerNameController.clear();
      _buyAtController.clear();
      _buyCountController.clear();
      _getCountController.clear();
      _selectedOfferType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Offers'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offer ID
            Text(
              'Offer ID',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _offerIDController,
              decoration: InputDecoration(
                hintText: 'Enter offer ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Offer Name
            Text(
              'Offer Name',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _offerNameController,
              decoration: InputDecoration(
                hintText: 'Enter offer name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Offer Type
            Text(
              'Offer Type',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedOfferType,
              decoration: InputDecoration(
                hintText: 'Select offer type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: _offerTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOfferType = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Buy At
            Text(
              'Buy At',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _buyAtController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter minimum purchase amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buy Count
            Text(
              'Buy Count',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _buyCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter buy count',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Get Count
            Text(
              'Get Count',
              style: AppTextStyles.label,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _getCountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter get count',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
