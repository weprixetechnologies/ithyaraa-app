import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/navigation/presentation/widgets/bottom_navigation.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/cart/presentation/providers/cart_provider.dart';
import 'features/wishlist/presentation/providers/wishlist_provider.dart';
import 'features/order/presentation/pages/order_confirmation_page.dart';
import 'features/product_detail/combo/presentation/pages/combo_product_pdp.dart';
import 'features/product_detail/makecombo/presentation/pages/make_combo_product_pdp.dart';
import 'features/flash_sale/presentation/pages/flash_sale_shop_page.dart';
import 'core/theme/app_text_styles.dart';
import 'core/navigation/auth_navigation_service.dart';

void main() {
  runApp(ProviderScope(overrides: [], child: const MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

final _navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends ConsumerState<MyApp> {
  bool _hasPrefetched = false;

  @override
  void initState() {
    super.initState();
    AuthNavigationService.init(
      _navigatorKey,
      ({String? redirectPath}) => MaterialPageRoute(
        builder: (_) => LoginPage(redirectPath: redirectPath),
      ),
      navigateToPath: _navigateToPath,
    );
    // Initialize auth provider on app startup to ensure tokens are loaded
    ref.read(authProvider);
  }

  /// Navigate to a path after login (e.g. combo:productID, makecombo:productID).
  /// Ensures home is at the bottom of the stack, then pushes the target route.
  void _navigateToPath(String path) {
    final state = _navigatorKey.currentState;
    if (state == null) return;
    // After login we may have an empty stack; ensure home is first.
    state.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BottomNavigationWidget()),
      (route) => false,
    );
    if (path.startsWith('combo:')) {
      final productID = path.substring(6).trim();
      if (productID.isNotEmpty) {
        state.push(
          MaterialPageRoute(
            builder: (_) => ComboProductPDP(productID: productID),
          ),
        );
      }
    } else if (path.startsWith('makecombo:')) {
      final productID = path.substring(10).trim();
      if (productID.isNotEmpty) {
        state.push(
          MaterialPageRoute(
            builder: (_) => MakeComboProductPDP(productID: productID),
          ),
        );
      }
    }
    // Other path formats can be added here (e.g. cart, wishlist).
  }

  /// Background prefetch of cart and wishlist when user is authenticated
  ///
  /// This method:
  /// - Runs in background (non-blocking)
  /// - Fetches cart and wishlist independently
  /// - Fails independently (one failure doesn't affect the other)
  /// - Only runs once per session (controlled by _hasPrefetched flag)
  void _prefetchCartAndWishlist() {
    if (_hasPrefetched) return;
    _hasPrefetched = true;

    // Use addPostFrameCallback to ensure this runs after the first frame is rendered
    // This prevents blocking the critical startup path and ensures smooth animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay slightly further to ensure UI is fully interactive
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        // Prefetch cart and wishlist independently
      // Don't await - let them run in parallel in background
      ref.read(cartControllerProvider.notifier).loadCart().catchError((error) {
        // Fail silently - cart page will handle retry
        debugPrint('[MyApp] Cart prefetch failed: $error');
      });

        ref.read(wishlistProvider.notifier).loadWishlist().catchError((error) {
          // Fail silently - wishlist page will handle retry
          // Note: loadWishlist is idempotent (has hydration check)
          debugPrint('[MyApp] Wishlist prefetch failed: $error');
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state to trigger prefetch when user becomes authenticated
    final authState = ref.watch(authProvider);

    // Listen to auth state changes and trigger prefetch when user logs in
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Trigger prefetch when user becomes authenticated
      // This handles both:
      // 1. Initial app startup (when tokens are restored)
      // 2. User login during session
      if (next.isLoggedIn && (previous == null || !previous.isLoggedIn)) {
        AuthNavigationService.clearLoginNavigationFlag();
        _prefetchCartAndWishlist();
      }
    });

    // Check current state in case auth was already restored
    if (authState.isLoggedIn && !_hasPrefetched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _prefetchCartAndWishlist();
      });
    }

    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Ithyaraa App',
      theme: ThemeData(
        fontFamily: 'Montserrat', // Default app font
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(255, 210, 50, 1.0),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.headingLarge,
          displayMedium: AppTextStyles.headingMedium,
          displaySmall: AppTextStyles.headingSmall,
          headlineMedium: AppTextStyles.cardTitle,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.button,
          labelMedium: AppTextStyles.label,
          labelSmall: AppTextStyles.caption,
        ),
      ),
      home: const BottomNavigationWidget(),
      onGenerateRoute: (settings) {
        if (settings.name == '/flash-sale') {
          return MaterialPageRoute(
            builder: (context) => const FlashSaleShopPage(),
            settings: settings,
          );
        }
        // Handle deep link: /order-status/order-summary/{orderID}
        if (settings.name != null &&
            settings.name!.startsWith('/order-status/order-summary/')) {
          final orderID = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(orderID: orderID),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
