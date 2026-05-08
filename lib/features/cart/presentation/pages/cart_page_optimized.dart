import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_price_breakdown.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';

/// OPTIMIZED Cart page
/// 
/// Performance optimizations:
/// - Selective provider watching (only needed fields)
/// - Stable keys for ListView items
/// - Animation stops when not needed
/// - Memoized state access
/// - No unnecessary ConsumerWidgets
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

  @override
  void dispose() {
    _animationController.dispose();
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX #1: Watch ONLY isLoggedIn, not entire auth provider
    final isLoggedIn = ref.watch(
      authProvider.select((state) => state.isLoggedIn),
    );

    if (!isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return Scaffold(
        appBar: AppBar(title: const Text('Cart')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // FIX #2: Watch ONLY isLoading with selector
    final isLoading = ref.watch(
      cartControllerProvider.select((state) => state.isLoading),
    );

    // FIX #3: Watch cartState with selector (only rebuilds when cartState changes)
    final cartState = ref.watch(
      cartControllerProvider.select((state) => state.cartState),
    );

    // FIX #4: Watch error with selector
    final error = ref.watch(
      cartControllerProvider.select((state) => state.error),
    );

    // FIX #5: Control animation based on loading state
    if (isLoading && cartState == null) {
      // Start animation only when loading
      if (!_animationController.isAnimating) {
        _animationController.repeat();
      }
    } else {
      // Stop animation when not loading
      if (_animationController.isAnimating) {
        _animationController.stop();
        _animationController.reset();
      }
    }

    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadingMessage = 'Getting Cart Securely';
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
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          setState(() {
            _loadingMessage = 'Getting Cart Securely';
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
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required cartState,
    required String? error,
    required controller,
  }) {
    // Show loading animation
    if (isLoading && cartState == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animationController,
              child: const Icon(
                Icons.shopping_cart,
                size: 64,
                color: Color.fromRGBO(255, 210, 50, 1.0),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _loadingMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(255, 210, 50, 1.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show error
    if (error != null && cartState == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadingMessage = 'Getting Cart Securely';
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
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show empty cart (no cart state loaded)
    if (cartState == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Handle empty cart (items array is empty but cart exists)
    if (cartState.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Your cart is empty',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show cart content
    // FIX #6: Use RepaintBoundary to isolate expensive list rendering
    return RepaintBoundary(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              // FIX #7: Add stable keys to prevent widget recreation
              key: const ValueKey('cart_items_list'),
              itemCount: cartState.items.length,
              itemBuilder: (context, index) {
                final item = cartState.items[index];
                // FIX #8: Use cartItemID as key for stable widget identity
                return CartItemTile(
                  key: ValueKey('cart_item_${item.cartItemID}'),
                  item: item,
                );
              },
            ),
          ),
          if (cartState.items.isNotEmpty)
            // FIX #9: Wrap price breakdown in RepaintBoundary
            RepaintBoundary(
              child: const CartPriceBreakdown(),
            ),
        ],
      ),
    );
  }
}
