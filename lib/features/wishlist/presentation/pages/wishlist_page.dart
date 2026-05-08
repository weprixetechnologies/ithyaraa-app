import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../shop/presentation/widgets/product_card/product_card.dart';
import '../providers/wishlist_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';

class WishlistPage extends ConsumerStatefulWidget {
  const WishlistPage({super.key});

  @override
  ConsumerState<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends ConsumerState<WishlistPage> {
  @override
  void initState() {
    super.initState();
    // Trigger load on open. The notifier handles hydration logic (prevents redundant calls).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).loadWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication - redirect to login if not authenticated
    final authState = ref.watch(authProvider);
    if (!authState.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return Scaffold(
        appBar: AppBar(title: const Text('My Wishlist')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(wishlistProvider);
    final items = state.items;
    final isLoading = state.isLoading;

    // Logic:
    // 1. If we have items: Show List (even if loading).
    // 2. If NO items and Loading: Show Loader.
    // 3. If NO items and Not Loading (and hydrated): Show Empty State.
    // 4. If error (and no items): Show Error.

    // STRICT RULE: "DO NOT EVER SHOW EMPTY PAGE IF DATA EXISTS"
    // So if (items.isNotEmpty) -> Show Grid.

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        actions: [
          if (isLoading && items.isNotEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (items.isNotEmpty) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 170 / 280, // Adjusted for card + text height
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ProductCard(
                  product: item.product,
                  onTap: () {
                    // Start navigation to product detail
                    // Navigator.pushNamed(context, '/product', arguments: item.product);
                  },
                );
              },
            );
          }

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(state.error!),
                  TextButton(
                    onPressed: () => ref
                        .read(wishlistProvider.notifier)
                        .loadWishlist(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty State
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Your wishlist is empty',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
