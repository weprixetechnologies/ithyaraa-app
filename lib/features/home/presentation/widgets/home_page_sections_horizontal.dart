import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/models/homepage_section_model.dart';
import '../providers/homepage_section_provider.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import '../../../shop/domain/entities/shop_filters.dart';

/// Horizontal scrollable widget for homepage sections
class HomePageSectionsHorizontal extends ConsumerWidget {
  const HomePageSectionsHorizontal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sectionsAsync = ref.watch(activeHomepageSectionsProvider);

    return sectionsAsync.when(
      data: (sections) {
        debugPrint(
          '[HOMEPAGE SECTIONS WIDGET] Received ${sections.length} sections',
        );
        // Hide widget if no sections
        if (sections.isEmpty) {
          debugPrint('[HOMEPAGE SECTIONS WIDGET] No sections, hiding widget');
          return const SizedBox.shrink();
        }

        debugPrint(
          '[HOMEPAGE SECTIONS WIDGET] Displaying ${sections.length} sections',
        );
        return SizedBox(
          height: 120, // 100px card + 20px spacing
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: sections.length,
            itemBuilder: (context, index) {
              final section = sections[index];
              debugPrint(
                '[HOMEPAGE SECTIONS WIDGET] Building card ${index + 1}: ${section.title}',
              );
              return _SectionCard(section: section);
            },
          ),
        );
      },
      loading: () {
        debugPrint('[HOMEPAGE SECTIONS WIDGET] Loading...');
        // Skeleton shimmer matching card size and spacing
        return SizedBox(
          height: 120, // Match card height (100) + vertical padding
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: 4,
            itemBuilder: (context, index) {
              return _SectionSkeletonCard(
                key: ValueKey('section_skeleton_$index'),
              );
            },
          ),
        );
      },
      error: (error, stackTrace) {
        // Fail silently - hide widget on error
        debugPrint('[HOMEPAGE SECTIONS WIDGET] Error: $error');
        debugPrint('[HOMEPAGE SECTIONS WIDGET] Stack trace: $stackTrace');
        return const SizedBox.shrink();
      },
    );
  }
}

/// Individual section card widget
class _SectionCard extends StatelessWidget {
  final HomepageSectionModel section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cached network image
              CachedNetworkImage(
                imageUrl: section.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),
              // Title overlay (if title exists)
              if (section.title != null && section.title!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      section.title!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final routeTo = section.routeTo ?? section.link;

    if (routeTo == null || routeTo.isEmpty) {
      return;
    }

    // If routeTo is "/shop" or "shop", navigate to ShopPage with filters
    // Handle both with and without leading slash, case-insensitive
    final normalizedRoute = routeTo.toLowerCase().replaceAll(RegExp(r'^/'), '');
    if (normalizedRoute == 'shop') {
      final shopFilters = _convertFiltersToShopFilters(section.filters);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShopPage(
            headerTitle: section.title ?? 'Shop',
            initialFilters: shopFilters,
          ),
        ),
      );
    } else {
      // For other routes, try to navigate using the route
      // This is a fallback - you may want to implement a routing service
      // For now, we'll just log it
      debugPrint('[HOMEPAGE SECTIONS] Unhandled route: $routeTo');
    }
  }

  /// Convert API filters Map to ShopFilters
  ShopFilters? _convertFiltersToShopFilters(Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      debugPrint('[HOMEPAGE SECTIONS] No filters to convert');
      return null;
    }

    debugPrint('[HOMEPAGE SECTIONS] Converting filters: $filters');

    // Parse categoryID - API may send as string or number
    List<int>? categoryIDs;
    if (filters.containsKey('categoryID')) {
      final categoryIDValue = filters['categoryID'];
      if (categoryIDValue != null) {
        if (categoryIDValue is String) {
          // Try to parse as int
          final parsed = int.tryParse(categoryIDValue);
          if (parsed != null && parsed > 0) {
            categoryIDs = [parsed];
          }
        } else if (categoryIDValue is int && categoryIDValue > 0) {
          categoryIDs = [categoryIDValue];
        } else if (categoryIDValue is num && categoryIDValue.toInt() > 0) {
          categoryIDs = [categoryIDValue.toInt()];
        }
      }
    }

    // Parse offerIDb
    String? offerID;
    if (filters.containsKey('offerID')) {
      final offerIDValue = filters['offerID'];
      if (offerIDValue != null) {
        offerID = offerIDValue.toString();
      }
    }

    // Parse type
    String? type;
    if (filters.containsKey('type')) {
      final typeValue = filters['type'];
      if (typeValue != null) {
        type = typeValue.toString();
      }
    }

    // If no explicit type provided, default to "variable" for shop sections
    type ??= 'variable';

    // Parse minPrice and maxPrice
    double? minPrice;
    if (filters.containsKey('minPrice')) {
      final minPriceValue = filters['minPrice'];
      if (minPriceValue != null) {
        if (minPriceValue is num) {
          minPrice = minPriceValue.toDouble();
        } else if (minPriceValue is String) {
          minPrice = double.tryParse(minPriceValue);
        }
      }
    }

    double? maxPrice;
    if (filters.containsKey('maxPrice')) {
      final maxPriceValue = filters['maxPrice'];
      if (maxPriceValue != null) {
        if (maxPriceValue is num) {
          maxPrice = maxPriceValue.toDouble();
        } else if (maxPriceValue is String) {
          maxPrice = double.tryParse(maxPriceValue);
        }
      }
    }

    // Parse sortBy
    String? sortBy;
    if (filters.containsKey('sortBy')) {
      final sortByValue = filters['sortBy'];
      if (sortByValue != null) {
        sortBy = sortByValue.toString();
      }
    }

    final shopFilters = ShopFilters(
      categoryIDs: categoryIDs,
      offerID: offerID,
      type: type,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );

    debugPrint(
      '[HOMEPAGE SECTIONS] Converted to ShopFilters: type=$type, offerID=$offerID, categoryIDs=$categoryIDs',
    );
    return shopFilters;
  }
}

/// Skeleton card shown while homepage sections are loading.
class _SectionSkeletonCard extends StatelessWidget {
  const _SectionSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          period: const Duration(milliseconds: 1200),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade200,
                  Colors.grey.shade300,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
