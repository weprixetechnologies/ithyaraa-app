import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../state/profile_provider.dart';

/// Profile header section - Zone 2: Profile Data Zone (API-dependent)
///
/// Features:
/// - Circular profile image with red border
/// - Name (bold, centered)
/// - Email (light gray, centered)
/// - Soft curved background shape
/// - Edit profile button
///
/// State Handling:
/// - Loading: Shows skeleton/placeholder
/// - Error: Shows fallback UI with default values
/// - Null: Shows default values (Ithyaraa User, ithyaraa.user@gmail.com)
/// - Success: Shows real profile data
///
/// Rule: This widget always renders - it never blocks the page.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profileState,
    this.onEditPressed,
  });

  final ProfileState profileState;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    // Determine what to display based on state
    final bool isLoading = profileState.isLoading;
    final bool hasError = profileState.error != null;
    final profile = profileState.profile;

    // Extract values with defaults
    final String displayName = profile?.name ?? 'Ithyaraa User';
    final String displayEmail = profile?.email ?? 'ithyaraa.user@gmail.com';
    final String? displayImageUrl = profile?.imageUrl;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background image positioned absolutely at the top
          Positioned(
            top: -20,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/profile-linear-line.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          // Foreground content with top padding to clear the image
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 40,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image with Red Border
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 3),
                  ),
                  child: ClipOval(
                    child: isLoading
                        ? _buildSkeletonImage()
                        : (displayImageUrl != null
                              ? Image.network(
                                  displayImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder();
                                  },
                                )
                              : _buildPlaceholder()),
                  ),
                ),
                const SizedBox(height: 16),

                // Name - show skeleton when loading
                isLoading
                    ? _buildSkeletonText(width: 150, height: 24)
                    : Text(
                        displayName,
                        style: AppTextStyles.headingSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                const SizedBox(height: 8),

                // Email - show skeleton when loading
                isLoading
                    ? _buildSkeletonText(width: 200, height: 16)
                    : Text(
                        displayEmail,
                        style: AppTextStyles.description.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),

                // Error indicator (subtle, doesn't block)
                if (hasError && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Unable to load profile',
                      style: AppTextStyles.description.copyWith(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // Edit Profile Button - always enabled
                OutlinedButton.icon(
                  onPressed: onEditPressed,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.person, size: 50, color: Colors.grey),
    );
  }

  /// Build skeleton image for loading state
  Widget _buildSkeletonImage() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  /// Build skeleton text for loading state
  Widget _buildSkeletonText({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
