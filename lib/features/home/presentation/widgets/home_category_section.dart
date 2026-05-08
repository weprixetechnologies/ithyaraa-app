import 'package:flutter/material.dart';
import '../../data/models/section_models.dart';
import '../../../shop/presentation/pages/shop_page.dart';
import '../../../shop/domain/entities/shop_filters.dart';

class HomeCategorySection extends StatelessWidget {
  final List<HomeCategory> categories;

  const HomeCategorySection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    // Chunk the categories into rows of 5
    final List<List<HomeCategory>> rows = [];
    for (var i = 0; i < categories.length; i += 5) {
      final end = (i + 5 < categories.length) ? i + 5 : categories.length;
      rows.add(categories.sublist(i, end));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Center(
              child: Text(
                "HOT CATEGORIES",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 22,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // Horizontal Scrollable Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows.map((row) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: row.map((cat) {
                      return _CategoryTile(category: cat);
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final HomeCategory category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.3;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopPage(
              headerTitle: category.categoryName,
              initialFilters: ShopFilters(
                categoryIDs: [category.categoryID],
              ),
            ),
          ),
        );
      },
      child: Container(
        width: width,
        margin: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            // Image
            if (category.imageUrl.isNotEmpty)
              Image.network(
                category.imageUrl,
                width: width,
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) => Container(
                  width: width,
                  height: width,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.category, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 8),
            // Title
            Text(
              category.categoryName.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
