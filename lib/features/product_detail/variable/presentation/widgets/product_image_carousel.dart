import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/product_image.dart';

/// Product image carousel with overlays and indicators
class ProductImageCarousel extends StatefulWidget {
  final List<ProductImageEntity> images;
  final int currentIndex;
  final double? rating;
  final int? reviewCount;
  final bool isWishlisted;
  final Function(int) onPageChanged;
  final VoidCallback? onImageTap;
  final VoidCallback? onQuickActionTap;

  const ProductImageCarousel({
    super.key,
    required this.images,
    required this.currentIndex,
    this.rating,
    this.reviewCount,
    this.isWishlisted = false,
    required this.onPageChanged,
    this.onImageTap,
    this.onQuickActionTap,
  });

  @override
  State<ProductImageCarousel> createState() => _ProductImageCarouselState();
}

class _ProductImageCarouselState extends State<ProductImageCarousel> {
  late PageController _pageController;
  final int _initialViewerCount = 50 + (DateTime.now().microsecondsSinceEpoch % 200);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(ProductImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If currentIndex changed externally (e.g., from gallery click), animate to that page
    if (oldWidget.currentIndex != widget.currentIndex &&
        _pageController.hasClients) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (widget.images.isEmpty) {
      return AspectRatio(
        aspectRatio: 170 / 222,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
          ),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Full-width image carousel with aspect ratio 170:222
        AspectRatio(
          aspectRatio: 170 / 222,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: widget.onPageChanged,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: widget.onImageTap,
                child: Image.network(
                  widget.images[index].imgUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  cacheHeight: 1045, // approx 170:222 ratio
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
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
            },
          ),
        ),
        
        // Viewing Status Capsule (Top-Left)
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '👀 ',
                  style: TextStyle(fontSize: 14),
                ),
                _FluctuatingViewerCount(initialCount: _initialViewerCount),
                const Text(
                  'OTHERS ARE VIEWING',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Rating & Review Capsule (Bottom-Left)
        if (widget.rating != null && widget.rating! > 0)
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.rating}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Color(0xFF2ECC71), // Emerald/Green star
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 1,
                    height: 12,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatReviewCount(widget.reviewCount),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Dot indicators
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: widget.currentIndex == index ? 12 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.currentIndex == index 
                        ? Colors.black 
                        : Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

        // Overlays
        // Wishlist icon (bottom-right) - pink heart overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: GestureDetector(
            onTap: widget.onQuickActionTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.pink.shade100.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: Colors.pink.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatReviewCount(int? count) {
    if (count == null) return '0';
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

/// A small widget that shows a number that fluctuates randomly
class _FluctuatingViewerCount extends StatefulWidget {
  final int initialCount;
  const _FluctuatingViewerCount({required this.initialCount});

  @override
  State<_FluctuatingViewerCount> createState() => _FluctuatingViewerCountState();
}

class _FluctuatingViewerCountState extends State<_FluctuatingViewerCount> {
  late int _currentCount;
  Timer? _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _currentCount = widget.initialCount;
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    _timer?.cancel();
    // Random interval between 3 and 10 seconds to feel natural
    final duration = Duration(seconds: 3 + _random.nextInt(8));
    _timer = Timer(duration, _updateCount);
  }

  void _updateCount() {
    if (!mounted) return;
    setState(() {
      // Fluctuate by -2 to +4 to simulate growth/churn
      final change = _random.nextInt(7) - 2;
      _currentCount = (_currentCount + change).clamp(10, 500);
    });
    _scheduleUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_currentCount ',
      style: const TextStyle(
        color: Color(0xFFE57373), // Reddish/Orange
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    );
  }
}
