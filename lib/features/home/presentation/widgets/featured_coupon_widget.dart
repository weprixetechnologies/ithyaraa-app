import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/featured_coupon_provider.dart';
import '../../data/models/section_models.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../checkout/presentation/providers/checkout_provider.dart';
import '../../../../core/theme/app_text_styles.dart';

class FeaturedCouponWidget extends ConsumerStatefulWidget {
  final FeaturedCoupon coupon;

  const FeaturedCouponWidget({super.key, required this.coupon});

  @override
  ConsumerState<FeaturedCouponWidget> createState() => _FeaturedCouponWidgetState();
}

class _FeaturedCouponWidgetState extends ConsumerState<FeaturedCouponWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showPopup() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => _FeaturedCouponPopup(coupon: widget.coupon),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      right: 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.1).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: GestureDetector(
              onTap: _showPopup,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.coupon.iconImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => const Icon(Icons.card_giftcard),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: GestureDetector(
              onTap: () {
                setState(() => _isVisible = false);
                // Clear persistent coupon
                ref.read(featuredCouponManagerProvider).clearCoupon();
                // Clear active coupon if any
                try {
                  ref.read(checkoutProvider.notifier).removeCoupon();
                } catch (e) {
                  debugPrint('Could not clear checkout coupon: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedCouponPopup extends ConsumerWidget {
  final FeaturedCoupon coupon;

  const _FeaturedCouponPopup({required this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              if (coupon.couponCode != null) {
                await ref.read(featuredCouponManagerProvider).saveCoupon(coupon.couponCode!);
                
                if (!context.mounted) return;
                
                // Show success toast-like popup
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'COUPON APPLIED YOU CAN CONTINUE SHOPPING',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );

                Navigator.pop(context); // Close dialog
                
                // Navigate to cart
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: coupon.popupImage,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tap on image to apply coupon',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
