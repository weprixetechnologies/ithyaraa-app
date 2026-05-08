import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../combo/domain/entities/combo_product.dart';
import '../../../variable/domain/entities/variation.dart';
import '../../../combo/presentation/widgets/combo_product_selector.dart';

/// Card for one selected product in Make Combo PDP: image, name, attributes, stock, remove.
class MakeComboSelectedProductCard extends StatelessWidget {
  final ComboProductEntity product;
  final VariationEntity? selectedVariation;
  final Map<String, String> selectedAttributes;
  final void Function(VariationEntity?, Map<String, String>) onVariationChanged;
  final VoidCallback onRemove;

  const MakeComboSelectedProductCard({
    super.key,
    required this.product,
    this.selectedVariation,
    this.selectedAttributes = const {},
    required this.onVariationChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isInStock = selectedVariation != null
        ? (selectedVariation!.inStock && selectedVariation!.stockQuantity > 0)
        : product.variations.any((v) => v.inStock && v.stockQuantity > 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildImage(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isInStock ? 'In Stock' : 'Out of Stock',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isInStock
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          if (product.variations.isNotEmpty) ...[
            const SizedBox(height: 12),
            ComboProductSelector(
              product: product,
              selectedVariation: selectedVariation,
              selectedAttributes: selectedAttributes,
              onVariationChanged: onVariationChanged,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImage() {
    String? url;
    if (product.featuredImage.isNotEmpty) {
      url = product.featuredImage.first.imgUrl;
    }
    return SizedBox(
      width: 72,
      height: 72,
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
