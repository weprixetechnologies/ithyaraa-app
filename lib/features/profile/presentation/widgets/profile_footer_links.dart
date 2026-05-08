import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Footer links section for profile page
/// 
/// Links:
/// - FAQs
/// - About Us
/// - Terms of use
/// - Privacy Policy
class ProfileFooterLinks extends StatelessWidget {
  const ProfileFooterLinks({
    super.key,
    this.onFAQsTap,
    this.onAboutUsTap,
    this.onTermsTap,
    this.onPrivacyTap,
  });

  final VoidCallback? onFAQsTap;
  final VoidCallback? onAboutUsTap;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 32),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildLink('FAQs', onFAQsTap),
          const SizedBox(height: 16),
          _buildLink('About Us', onAboutUsTap),
          const SizedBox(height: 16),
          _buildLink('Terms of use', onTermsTap),
          const SizedBox(height: 16),
          _buildLink('Privacy Policy', onPrivacyTap),
        ],
      ),
    );
  }

  Widget _buildLink(String text, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap ?? () {
        // Placeholder for link tap
      },
      child: Text(
        text,
        style: AppTextStyles.link,
      ),
    );
  }
}
