import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../combo/domain/entities/combo_product.dart';

/// Full-screen modal to select up to [maxProducts] products for the Make Combo.
/// Tap a product to toggle selection. Apply validates at least one product and closes.
class MakeComboProductSelectionModal extends StatelessWidget {
  final List<ComboProductEntity> eligibleProducts;
  final List<ComboProductEntity> currentSelection;
  final int maxProducts;
  final ValueChanged<List<ComboProductEntity>> onApply;

  const MakeComboProductSelectionModal({
    super.key,
    required this.eligibleProducts,
    required this.currentSelection,
    this.maxProducts = 3,
    required this.onApply,
  });

  static Future<List<ComboProductEntity>?> show(
    BuildContext context, {
    required List<ComboProductEntity> eligibleProducts,
    required List<ComboProductEntity> currentSelection,
    int maxProducts = 3,
  }) async {
    return showModalBottomSheet<List<ComboProductEntity>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalContent(
        eligibleProducts: eligibleProducts,
        currentSelection: currentSelection,
        maxProducts: maxProducts,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _ModalContent extends StatefulWidget {
  final List<ComboProductEntity> eligibleProducts;
  final List<ComboProductEntity> currentSelection;
  final int maxProducts;

  const _ModalContent({
    required this.eligibleProducts,
    required this.currentSelection,
    required this.maxProducts,
  });

  @override
  State<_ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<_ModalContent> {
  late List<ComboProductEntity> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<ComboProductEntity>.from(widget.currentSelection);
  }

  bool _isSelected(ComboProductEntity product) {
    return _selected.any((p) => p.productID == product.productID);
  }

  void _toggle(ComboProductEntity product) {
    setState(() {
      if (_isSelected(product)) {
        _selected.removeWhere((p) => p.productID == product.productID);
      } else {
        if (_selected.length >= widget.maxProducts) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can select at most ${widget.maxProducts} products',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        _selected.add(product);
      }
    });
  }

  void _apply() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one product'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: widget.eligibleProducts.isEmpty
                ? const Center(child: Text('No products available'))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: widget.eligibleProducts.length,
                    itemBuilder: (context, index) {
                      final product = widget.eligibleProducts[index];
                      return _ProductTile(
                        product: product,
                        isSelected: _isSelected(product),
                        onTap: () => _toggle(product),
                      );
                    },
                  ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            'Select Products (${_selected.length}/${widget.maxProducts})',
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _apply,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(255, 210, 50, 1.0),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Apply Selection'),
          ),
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ComboProductEntity product;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.isSelected,
    required this.onTap,
  });

  String? get _imageUrl {
    if (product.featuredImage.isEmpty) return null;
    return product.featuredImage.first.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: _imageUrl != null
                        ? Image.network(
                            _imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(255, 210, 50, 1.0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                product.name,
                style: AppTextStyles.cardTitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_not_supported, color: Colors.grey),
      ),
    );
  }
}
