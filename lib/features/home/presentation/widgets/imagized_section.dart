import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/section_models.dart';

class ImagizedSection extends StatelessWidget {
  final ImageSection section;
  final List<ImageItem> images;

  const ImagizedSection({
    super.key,
    required this.section,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final layout = section.layoutID ?? '1';
    Widget content;
    switch (layout) {
      case '1':
        content = _oneImage(context);
        break;
      case '2':
        content = _twoImages(context);
        break;
      case '3':
        content = _threeImages(context);
        break;
      case '4':
        content = _fourImages(context);
        break;
      default:
        content = _oneImage(context);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Center(
              child: Text(
                section.title.toUpperCase(), // Uppercase for more emphasis
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900, // Extra bold
                      letterSpacing: 1.5,
                      fontSize: 22, // Enlarged
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _oneImage(BuildContext context) {
    final img = images.isNotEmpty ? images[0].imageUrl : '';
    return _imageBox(img);
  }

  Widget _twoImages(BuildContext context) {
    final a = images.isNotEmpty ? images[0].imageUrl : '';
    final b = images.length > 1 ? images[1].imageUrl : '';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _imageBox(a)),
        Expanded(child: _imageBox(b)),
      ],
    );
  }

  Widget _threeImages(BuildContext context) {
    final a = images.isNotEmpty ? images[0].imageUrl : '';
    final b = images.length > 1 ? images[1].imageUrl : '';
    final c = images.length > 2 ? images[2].imageUrl : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _imageBox(a),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _imageBox(b)),
            Expanded(child: _imageBox(c)),
          ],
        ),
      ],
    );
  }

  Widget _fourImages(BuildContext context) {
    final imgs = List.generate(
      4,
      (i) => images.length > i ? images[i].imageUrl : '',
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _imageBox(imgs[0])),
            Expanded(child: _imageBox(imgs[1])),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _imageBox(imgs[2])),
            Expanded(child: _imageBox(imgs[3])),
          ],
        ),
      ],
    );
  }

  Widget _imageBox(String url) {
    if (url.isEmpty) return const SizedBox.shrink();
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      placeholder: (_, __) => Container(color: Colors.grey.shade200),
      errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200),
    );
  }
}
