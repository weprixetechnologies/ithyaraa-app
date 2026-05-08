import 'package:flutter/material.dart';
import 'image_slider.dart';

/// Example usage of the ImageSlider widget
/// 
/// This demonstrates how to use the ImageSlider with dummy image URLs.
/// Replace the dummy URLs with your actual API endpoints when ready.
class ImageSliderExample extends StatelessWidget {
  const ImageSliderExample({super.key});

  /// Dummy image URLs for testing
  /// Replace these with your actual API endpoints
  static const List<String> dummyImageUrls = [
    'https://picsum.photos/800/800?random=1',
    'https://picsum.photos/800/800?random=2',
    'https://picsum.photos/800/800?random=3',
    'https://picsum.photos/800/800?random=4',
    'https://picsum.photos/800/800?random=5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Slider Example'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // Basic usage
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Basic Image Slider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ImageSlider(
              imageUrls: dummyImageUrls,
              onImageTap: (index) {
                debugPrint('Tapped image at index: $index');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tapped image ${index + 1}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // With auto-play
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Auto-Play Slider (3 seconds)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ImageSlider(
              imageUrls: dummyImageUrls,
              autoPlayIntervalSeconds: 3,
              onImageTap: (index) {
                debugPrint('Tapped auto-play image at index: $index');
              },
            ),
            
            const SizedBox(height: 40),
            
            // Custom styling
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Custom Styled Slider',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ImageSlider(
              imageUrls: dummyImageUrls.take(3).toList(),
              borderRadius: 24.0,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              indicatorColor: Colors.grey,
              activeIndicatorColor: Colors.blue,
              onImageTap: (index) {
                debugPrint('Tapped custom styled image at index: $index');
              },
            ),
            
            const SizedBox(height: 40),
            
            // Without indicators
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Slider Without Indicators',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ImageSlider(
              imageUrls: dummyImageUrls.take(2).toList(),
              showIndicators: false,
              onImageTap: (index) {
                debugPrint('Tapped image without indicators at index: $index');
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

/// Integration example for HomePage
/// 
/// To integrate into your HomePage, add this widget:
/// 
/// ```dart
/// // In your HomePage build method:
/// ImageSlider(
///   imageUrls: [
///     'https://your-api.com/banner1.jpg',
///     'https://your-api.com/banner2.jpg',
///     'https://your-api.com/banner3.jpg',
///   ],
///   autoPlayIntervalSeconds: 5, // Optional: auto-play every 5 seconds
///   onImageTap: (index) {
///     // Handle image tap - navigate to product, category, etc.
///     debugPrint('Banner $index tapped');
///   },
/// )
/// ```
/// 
/// When ready to integrate with API:
/// 1. Replace dummy URLs with API endpoint
/// 2. Use Riverpod/Provider to fetch image URLs
/// 3. Handle loading/error states at the parent level
/// 
/// Example with Riverpod:
/// ```dart
/// final bannerUrlsProvider = FutureProvider<List<String>>((ref) async {
///   final response = await apiService.getBanners();
///   return response.map((banner) => banner.imageUrl).toList();
/// });
/// 
/// // In widget:
/// final bannerUrlsAsync = ref.watch(bannerUrlsProvider);
/// 
/// return bannerUrlsAsync.when(
///   data: (urls) => ImageSlider(imageUrls: urls),
///   loading: () => ImageSliderSkeleton(),
///   error: (_, __) => const SizedBox.shrink(),
/// );
/// ```
