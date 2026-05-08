import 'package:flutter/material.dart';
import '../../domain/entities/product_image.dart';

/// Gallery thumbnail strip widget
class GalleryStrip extends StatelessWidget {
  final List<ProductImageEntity> galleryImages;
  final ProductImageEntity? selectedImage;
  final Function(ProductImageEntity) onImageSelected;

  const GalleryStrip({
    super.key,
    required this.galleryImages,
    this.selectedImage,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (galleryImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: galleryImages.length,
        itemBuilder: (context, index) {
          final image = galleryImages[index];
          final isSelected = selectedImage?.imgUrl == image.imgUrl;

          return GestureDetector(
            onTap: () => onImageSelected(image),
            child: Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? const Color(0xFFE91E63) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  image.imgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 32),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
