import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// A section to display product reviews
class ReviewsSection extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const ReviewsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    const themeColor = Color.fromRGBO(255, 210, 50, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Reviews',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              if (reviewCount > 0)
                Text(
                  'View All',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        if (reviewCount == 0)
          const Padding(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
            child: Text(
              'No reviews yet. Be the first to review this product!',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildSummary(themeColor),
                const SizedBox(height: 24),
                // Placeholder for actual reviews
                _buildReviewItem(
                  'John Doe',
                  5.0,
                  'Excellent product! The quality is top-notch and it fits perfectly. Highly recommended.',
                  '2 days ago',
                  themeColor,
                ),
                const Divider(height: 32),
                _buildReviewItem(
                  'Jane Smith',
                  4.0,
                  'Very good value for money. The color is slightly different from the pictures but still looks great.',
                  '1 week ago',
                  themeColor,
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummary(Color themeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  final starValue = index + 1;
                  return Icon(
                    rating >= starValue
                        ? Icons.star
                        : (rating >= starValue - 0.5
                            ? Icons.star_half
                            : Icons.star_border),
                    size: 16,
                    color: themeColor,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                'Based on $reviewCount reviews',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.8, themeColor),
                _buildRatingBar(4, 0.15, themeColor),
                _buildRatingBar(3, 0.05, themeColor),
                _buildRatingBar(2, 0.0, themeColor),
                _buildRatingBar(1, 0.0, themeColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, double percentage, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              stars.toString(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 10, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    String name,
    double rating,
    String comment,
    String date,
    Color themeColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            Text(
              date,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(5, (index) {
            return Icon(
              index < rating ? Icons.star : Icons.star_border,
              size: 14,
              color: themeColor,
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          comment,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
