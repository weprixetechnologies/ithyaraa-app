import 'package:flutter/material.dart';
import '../../domain/entities/offer.dart';

class ProductOfferBanner extends StatefulWidget {
  final OfferEntity offer;

  const ProductOfferBanner({
    super.key,
    required this.offer,
  });

  @override
  State<ProductOfferBanner> createState() => _ProductOfferBannerState();
}

class _ProductOfferBannerState extends State<ProductOfferBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<Color?> _borderColorAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.amber.shade200,
      end: Colors.amber.shade700,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offer.offerType != 'buy_x_get_y') {
      return const SizedBox.shrink(); 
    }

    final buyCount = widget.offer.buyCount;
    final getCount = widget.offer.getCount;
    final totalRequired = buyCount + getCount;
    final mainTitle = 'Buy $buyCount Get $getCount FREE';

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: _borderColorAnimation.value ?? Colors.amber,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: (_borderColorAnimation.value ?? Colors.amber).withValues(alpha: 0.3),
                blurRadius: 8.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flame icon
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE8A1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  '🔥',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LIMITED OFFER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC05600),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      mainTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4A2B0F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5D4037),
                        ),
                        children: [
                          const TextSpan(text: '👉 '),
                          TextSpan(
                            text: widget.offer.offerName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: ' — applied automatically at checkout',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              
              // Right Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.shade600),
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                child: Text(
                  'Add $totalRequired to cart\nto unlock',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8D4004),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
