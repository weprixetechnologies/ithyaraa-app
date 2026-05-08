import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer skeleton loader for image slider
/// 
/// Provides a smooth shimmer effect while images are loading.
/// Maintains 1:1 aspect ratio to match the actual image dimensions.
class ImageSliderSkeleton extends StatelessWidget {
  /// Border radius for the skeleton (matches image slider)
  final double borderRadius;
  
  /// Optional height override (defaults to full width for 1:1 aspect ratio)
  final double? height;

  const ImageSliderSkeleton({
    super.key,
    this.borderRadius = 16.0,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.grey.shade300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            period: const Duration(milliseconds: 1200),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
