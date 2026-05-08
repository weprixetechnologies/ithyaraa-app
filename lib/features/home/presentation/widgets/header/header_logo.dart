import 'package:flutter/material.dart';

/// App logo widget for Home Header
///
/// Stateless widget - displays app logo image
/// Uses image asset for branding consistency
class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: 50,
      fit: BoxFit.contain,
      semanticLabel: 'Ithyaraa Logo',
      errorBuilder: (context, error, stackTrace) {
        // Fallback to text if image fails to load
        return const Text(
          'Ithyaraa',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        );
      },
    );
  }
}
