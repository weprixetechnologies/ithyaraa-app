import 'package:flutter/material.dart';
import '../../domain/entities/product_image.dart';

/// Hero image viewer widget
class ProductImageViewer extends StatelessWidget {
  final ProductImageEntity? image;
  final VoidCallback? onTap;

  const ProductImageViewer({
    super.key,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null) {
      return Container(
        height: 400,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Image.network(
        image!.imgUrl,
        width: double.infinity,
        height: 400,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 400,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 400,
            color: Colors.grey.shade100,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
