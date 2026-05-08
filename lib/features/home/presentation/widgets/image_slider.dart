import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'image_slider_skeleton.dart';

/// Modern, production-ready image slider widget
/// 
/// Features:
/// - 1:1 aspect ratio on all screen sizes
/// - Smooth, lag-free scrolling with PageView.builder
/// - Lazy loading (only visible images are rendered)
/// - Image caching via CachedNetworkImage
/// - Shimmer skeleton loader while loading
/// - Graceful error handling
/// - Modern UI with rounded corners and clean spacing
/// - Optimized to prevent unnecessary rebuilds and jank
/// 
/// Usage:
/// ```dart
/// ImageSlider(
///   imageUrls: [
///     'https://example.com/image1.jpg',
///     'https://example.com/image2.jpg',
///   ],
///   onImageTap: (index) => debugPrint('Tapped image $index'),
/// )
/// ```
class ImageSlider extends StatefulWidget {
  /// List of image URLs to display
  final List<String> imageUrls;
  
  /// Callback when an image is tapped
  final void Function(int index)? onImageTap;
  
  /// Border radius for images (default: 16.0)
  final double borderRadius;
  
  /// Padding around the slider (default: EdgeInsets.symmetric(horizontal: 16))
  final EdgeInsets padding;
  
  /// Height of the slider (default: null, uses full width with 1:1 aspect ratio)
  final double? height;
  
  /// Auto-play interval in seconds (default: null, no auto-play)
  final int? autoPlayIntervalSeconds;
  
  /// Show page indicators (default: true)
  final bool showIndicators;
  
  /// Color for page indicators (default: Colors.white)
  final Color indicatorColor;
  
  /// Color for active page indicator (default: Colors.white70)
  final Color activeIndicatorColor;

  ImageSlider({
    super.key,
    required this.imageUrls,
    this.onImageTap,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.height,
    this.autoPlayIntervalSeconds,
    this.showIndicators = true,
    this.indicatorColor = Colors.white,
    this.activeIndicatorColor = Colors.white70,
  }) : assert(imageUrls.isNotEmpty, 'imageUrls cannot be empty');

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  /// Start auto-play if interval is specified
  void _startAutoPlay() {
    if (widget.autoPlayIntervalSeconds != null && widget.imageUrls.length > 1) {
      _autoPlayTimer = Timer.periodic(
        Duration(seconds: widget.autoPlayIntervalSeconds!),
        (_) {
          if (!mounted) return;
          final nextPage = (_currentPage + 1) % widget.imageUrls.length;
          _pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      );
    }
  }

  /// Stop auto-play (e.g., when user manually swipes)
  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  /// Resume auto-play after user interaction
  void _resumeAutoPlay() {
    if (_autoPlayTimer == null && widget.autoPlayIntervalSeconds != null) {
      _startAutoPlay();
    }
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _currentPage = index;
      });
      // Stop auto-play when user manually swipes, then resume after delay
      _stopAutoPlay();
      // Resume auto-play after a delay to allow user to continue swiping
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _resumeAutoPlay();
        }
      });
    }
  }

  void _onImageTap(int index) {
    widget.onImageTap?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image slider
          AspectRatio(
            aspectRatio: 1.0,
            child: SizedBox(
              height: widget.height,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: widget.imageUrls.length,
                // Optimize scrolling performance
                physics: const BouncingScrollPhysics(),
                // Only build visible pages (lazy loading)
                itemBuilder: (context, index) {
                  return _ImageSliderItem(
                    imageUrl: widget.imageUrls[index],
                    borderRadius: widget.borderRadius,
                    onTap: () => _onImageTap(index),
                  );
                },
              ),
            ),
          ),
          
          // Page indicators
          if (widget.showIndicators && widget.imageUrls.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _PageIndicators(
                count: widget.imageUrls.length,
                currentIndex: _currentPage,
                color: widget.indicatorColor,
                activeColor: widget.activeIndicatorColor,
              ),
            ),
        ],
      ),
    );
  }
}

/// Individual image item in the slider
/// 
/// Optimized to prevent unnecessary rebuilds using const constructors
/// and memoization where possible.
class _ImageSliderItem extends StatelessWidget {
  final String imageUrl;
  final double borderRadius;
  final VoidCallback onTap;

  const _ImageSliderItem({
    required this.imageUrl,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            // Use placeholder with shimmer effect
            placeholder: (context, url) => ImageSliderSkeleton(
              borderRadius: borderRadius,
            ),
            // Error state
            errorWidget: (context, url, error) => _ErrorWidget(
              borderRadius: borderRadius,
            ),
            // Cache configuration for optimal performance
            memCacheWidth: 800, // Limit memory cache size
            memCacheHeight: 800,
            // Fade in animation for smooth loading
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 100),
          ),
        ),
      ),
    );
  }
}

/// Error widget for failed image loads
class _ErrorWidget extends StatelessWidget {
  final double borderRadius;

  const _ErrorWidget({
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.grey.shade200,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Page indicators for the slider
class _PageIndicators extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color color;
  final Color activeColor;

  const _PageIndicators({
    required this.count,
    required this.currentIndex,
    required this.color,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex ? activeColor : color,
          ),
        ),
      ),
    );
  }
}
