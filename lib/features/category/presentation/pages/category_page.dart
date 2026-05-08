import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/category_controller.dart';
import '../providers/category_provider.dart';
import '../widgets/category_header.dart';
import '../widgets/category_card.dart';
import '../../../../features/shop/presentation/pages/shop_page.dart';
import '../../../../features/shop/domain/entities/shop_filters.dart';
import '../../../../features/navigation/presentation/providers/navigation_provider.dart';

/// Category page - tab page in bottom navigation
class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  @override
  void initState() {
    super.initState();
    // Load categories on first visit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryControllerProvider.notifier).loadCategories();
    });
  }

  void _onBackPressed() {
    // Navigate to home page in bottom navigation
    ref.read(navigationProvider.notifier).setIndex(0);
  }

  void _onCategoryTap(category) {
    // Ensure categoryID is valid before navigation
    if (category.categoryID == null || category.categoryID <= 0) {
      debugPrint(
        '[CATEGORY PAGE] Warning: Invalid categoryID: ${category.categoryID}',
      );
      return;
    }

    debugPrint(
      '[CATEGORY PAGE] Navigating to ShopPage with categoryID: ${category.categoryID}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopPage(
          headerTitle: category.categoryName,
          initialFilters: ShopFilters(
            categoryIDs: [category.categoryID],
            // Default to variable type for category-based navigation
            type: 'variable',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryState = ref.watch(categoryControllerProvider);
    final categoryController = ref.read(categoryControllerProvider.notifier);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            // Header
            CategoryHeader(
              topPadding: statusBarHeight,
              onBackPressed: _onBackPressed,
              onSearchPressed: () {
                // TODO: Implement search
              },
              onCartPressed: () {
                // TODO: Navigate to cart
              },
            ),
            // Category Grid
            Expanded(child: _buildContent(categoryState, categoryController)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CategoryState state, CategoryController controller) {
    if (state.isLoading && state.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadCategories(force: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: state.categories.length,
        itemBuilder: (context, index) {
          final category = state.categories[index];
          return CategoryCard(
            category: category,
            onTap: () => _onCategoryTap(category),
          );
        },
      ),
    );
  }
}
