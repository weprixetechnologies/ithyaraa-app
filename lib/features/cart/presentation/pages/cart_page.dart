import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../controllers/cart_controller.dart';
import '../../domain/entities/cart_state.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_price_breakdown.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../home/presentation/providers/featured_coupon_provider.dart';
import '../../../checkout/presentation/providers/checkout_provider.dart';

/// Cart page
/// Loads cart on visit, shows loading animation
/// No watching for updates - only loads when page is visited
class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _messageTimer;
  String _loadingMessage = 'Getting Cart Securely';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // DO NOT call .repeat() here - only start when loading

    // Load cart when page is visited
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartControllerProvider.notifier).loadCart();
      _checkAndApplyFeaturedCoupon();
    });

    // Switch message after 1.5 seconds
    _messageTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _loadingMessage = 'Almost There';
        });
      }
    });
  }

  Future<void> _checkAndApplyFeaturedCoupon() async {
    final couponCode = await ref
        .read(featuredCouponManagerProvider)
        .getSavedCoupon();
    if (couponCode != null) {
      final cartState = ref.read(cartControllerProvider).cartState;
      if (cartState != null && cartState.items.isNotEmpty) {
        // Apply coupon using checkout provider
        await ref
            .read(checkoutProvider.notifier)
            .applyCoupon(
              couponCode,
              cartID: cartState.cartID != null
                  ? int.tryParse(cartState.cartID!)
                  : null,
            );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ONLY isLoggedIn, not entire auth provider
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Watch values with selectors for performance
    final isLoading = ref.watch(
      cartControllerProvider.select((state) => state.isLoading),
    );

    final cartState = ref.watch(
      cartControllerProvider.select((state) => state.cartState),
    );

    final error = ref.watch(
      cartControllerProvider.select((state) => state.error),
    );

    final isDeleting = ref.watch(
      cartControllerProvider.select((state) => state.isDeleting),
    );

    // Control animation based on loading state
    if (isLoading && cartState == null) {
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    }

    final controller = ref.read(cartControllerProvider.notifier);
    final itemCount = cartState?.items.length ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Cart',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (itemCount > 0)
              Text(
                '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: Colors.grey.shade800),
            onPressed: () {
              setState(() {
                _loadingMessage = 'Updating Cart';
              });
              _messageTimer?.cancel();
              _messageTimer = Timer(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() {
                    _loadingMessage = 'Almost There';
                  });
                }
              });
              controller.refresh();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFFD232),
        backgroundColor: Colors.white,
        onRefresh: () {
          setState(() {
            _loadingMessage = 'Updating Cart';
          });
          _messageTimer?.cancel();
          _messageTimer = Timer(const Duration(milliseconds: 1500), () {
            if (mounted) {
              setState(() {
                _loadingMessage = 'Almost There';
              });
            }
          });
          return controller.refresh();
        },
        child: _buildBody(
          isLoading: isLoading,
          cartState: cartState,
          error: error,
          isDeleting: isDeleting,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required CartState? cartState,
    required String? error,
    required bool isDeleting,
    required CartController controller,
  }) {
    // Show loading animation
    if (isLoading && cartState == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: RotationTransition(
                turns: _animationController,
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  size: 48,
                  color: Color(0xFFFFD232),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _loadingMessage,
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Securely fetching your items...',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                minHeight: 4,
                backgroundColor: Color(0xFFEEEEEE),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD232)),
              ),
            ),
          ],
        ),
      );
    }

    // Show error
    if (error != null && cartState == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.headingSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _loadingMessage = 'Retrying...';
                  });
                  controller.refresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty cart
    if (cartState == null || cartState.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Your cart is empty',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Looks like you haven\'t added anything\nto your cart yet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD232),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Start Shopping',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show cart content
    final localSelected = ref.watch(cartControllerProvider.select((s) => s.localSelectedItems)) ?? {};
    final allSelected = cartState.items.isNotEmpty && cartState.items.every((i) => localSelected.contains(i.cartItemID));

    return Stack(
      children: [
        Column(
          children: [
            // Select All Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: allSelected,
                    tristate: true,
                    activeColor: const Color(0xFFFFD232),
                    checkColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      // If not all are selected, select all.
                      // If all are selected, deselect all.
                      controller.toggleAllLocalSelection(!allSelected);
                    },
                    fillColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFFFFD232);
                      }
                      return Colors.white;
                    }),
                  ),
                  GestureDetector(
                    onTap: () => controller.toggleAllLocalSelection(!allSelected),
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All Items',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${localSelected.length}/${cartState.items.length} Selected',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9), indent: 16, endIndent: 16),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                key: const ValueKey('cart_items_list'),
                itemCount: cartState.items.length,
                itemBuilder: (context, index) {
                  final item = cartState.items[index];
                  return CartItemTile(
                    key: ValueKey('cart_item_${item.cartItemID}'),
                    item: item,
                  );
                },
              ),
            ),
            if (cartState.items.isNotEmpty)
              const RepaintBoundary(child: CartPriceBreakdown()),
          ],
        ),
        // Blocking loader overlay when deleting
        if (isDeleting) _buildDeletingOverlay(),
      ],
    );
  }

  Widget _buildDeletingOverlay() {
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD232),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Removing Item...',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
