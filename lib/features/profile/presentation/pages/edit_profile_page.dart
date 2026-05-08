import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../state/profile_provider.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/presentation/widgets/auth_input_field.dart';
import '../../../auth/presentation/widgets/error_message_widget.dart';
import '../providers/profile_api_providers.dart';
import '../../../../core/services/bunny_cdn_service.dart';

/// Edit Profile page
///
/// Features:
/// - Displays current profile data from provider (no API call on open)
/// - Allows editing name and profile photo URL
/// - Refetch button to refresh profile data
/// - Save button to update profile
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _emailOtpController;
  late TextEditingController _phoneOtpController;

  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImageFile;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  bool _isLoading = false;
  String? _error;
  bool _isEmailVerifying = false;
  bool _isPhoneVerifying = false;
  bool _isEmailOtpSent = false;
  bool _isPhoneOtpSent = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _emailOtpController = TextEditingController();
    _phoneOtpController = TextEditingController();
  }

  void _loadProfileData(WidgetRef ref) {
    final profileState = ref.read(profileProvider);
    if (profileState.profile != null) {
      _nameController.text = profileState.profile!.name;
      _emailController.text = profileState.profile!.email;
      _phoneController.text = profileState.profile!.phone;
      _uploadedImageUrl = profileState.profile!.imageUrl;
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      // Pick image from gallery
      final XFile? pickedFile = await _imagePicker
          .pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: 1024,
            maxHeight: 1024,
          )
          .catchError((error) {
            debugPrint('[IMAGE PICKER] Error: $error');
            if (mounted) {
              setState(() {
                _error = 'Failed to pick image. Please try again.';
              });
            }
            return null;
          });

      if (pickedFile == null) return;

      final imageFile = File(pickedFile.path);
      setState(() {
        _selectedImageFile = imageFile;
        _isUploadingImage = true;
        _error = null;
      });

      // Upload to Bunny CDN
      final bunnyService = BunnyCdnService();
      final uploadedUrl = await bunnyService.uploadImage(imageFile);

      setState(() {
        _uploadedImageUrl = uploadedUrl;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image uploaded successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _error = _cleanErrorMessage(e.toString());
        });
      }
    }
  }

  Future<void> _handleSendEmailOtp() async {
    if (_isLoading || _isEmailVerifying) return;

    setState(() {
      _isEmailVerifying = true;
      _error = null;
    });

    try {
      final sendOtpUseCase = ref.read(sendVerificationOtpUseCaseProvider);
      await sendOtpUseCase(_emailController.text.trim());

      if (mounted) {
        setState(() {
          _isEmailOtpSent = true;
          _isEmailVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your email'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
          _isEmailVerifying = false;
        });
      }
    }
  }

  Future<void> _handleVerifyEmailOtp() async {
    if (_isLoading || _isEmailVerifying) return;

    final otp = _emailOtpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        _error = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isEmailVerifying = true;
      _error = null;
    });

    try {
      final verifyOtpUseCase = ref.read(verifyOtpUseCaseProvider);
      await verifyOtpUseCase(_emailController.text.trim(), otp);

      // Refresh profile to get updated verification status
      final notifier = ref.read(profileProvider.notifier);
      await notifier.initializeProfile();

      if (mounted) {
        setState(() {
          _isEmailOtpSent = false;
          _isEmailVerifying = false;
          _emailOtpController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
          _isEmailVerifying = false;
        });
      }
    }
  }

  Future<void> _handleSendPhoneOtp() async {
    if (_isLoading || _isPhoneVerifying) return;

    setState(() {
      _isPhoneVerifying = true;
      _error = null;
    });

    try {
      final sendOtpUseCase = ref.read(sendVerificationOtpUseCaseProvider);
      await sendOtpUseCase(_phoneController.text.trim());

      if (mounted) {
        setState(() {
          _isPhoneOtpSent = true;
          _isPhoneVerifying = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your phone'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
          _isPhoneVerifying = false;
        });
      }
    }
  }

  Future<void> _handleVerifyPhoneOtp() async {
    if (_isLoading || _isPhoneVerifying) return;

    final otp = _phoneOtpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        _error = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isPhoneVerifying = true;
      _error = null;
    });

    try {
      final verifyOtpUseCase = ref.read(verifyOtpUseCaseProvider);
      await verifyOtpUseCase(_phoneController.text.trim(), otp);

      // Refresh profile to get updated verification status
      final notifier = ref.read(profileProvider.notifier);
      await notifier.initializeProfile();

      if (mounted) {
        setState(() {
          _isPhoneOtpSent = false;
          _isPhoneVerifying = false;
          _phoneOtpController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone verified successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
          _isPhoneVerifying = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _emailOtpController.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  /// Cleans error messages to be more user-friendly
  String _cleanErrorMessage(String error) {
    if (error.startsWith('Exception: ')) {
      error = error.substring(11);
    }
    if (error.startsWith('Failed to ')) {
      error = error.substring(10);
    }
    return error.trim();
  }

  Future<void> _handleRefetch() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifier = ref.read(profileProvider.notifier);
      await notifier.initializeProfile();

      // Reload data after refetch
      _loadProfileData(ref);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile refreshed successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Name cannot be empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifier = ref.read(profileProvider.notifier);
      await notifier.updateProfile(
        name: _nameController.text.trim(),
        profilePhoto: _uploadedImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _cleanErrorMessage(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // Load profile data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_nameController.text.isEmpty && profileState.profile != null) {
        _loadProfileData(ref);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.headingMedium),
        centerTitle: true,
        actions: [
          // Refetch button
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoading ? null : _handleRefetch,
            tooltip: 'Refresh profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Preview with Upload
            Center(
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 3),
                    ),
                    child: ClipOval(
                      child: _isUploadingImage
                          ? Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _selectedImageFile != null
                          ? Image.file(_selectedImageFile!, fit: BoxFit.cover)
                          : (_uploadedImageUrl != null &&
                                    _uploadedImageUrl!.isNotEmpty) ||
                                (profileState.profile?.imageUrl != null &&
                                    profileState.profile!.imageUrl!.isNotEmpty)
                          ? Image.network(
                              _uploadedImageUrl ??
                                  profileState.profile?.imageUrl ??
                                  '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  // Upload button overlay
                  Positioned(
                    bottom: 20,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickAndUploadImage,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isUploadingImage
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: TextButton.icon(
                onPressed: _isUploadingImage ? null : _pickAndUploadImage,
                icon: const Icon(Icons.upload, size: 18),
                label: Text(
                  _isUploadingImage ? 'Uploading...' : 'Upload New Photo',
                  style: AppTextStyles.link,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            Text('Name', style: AppTextStyles.label),
            const SizedBox(height: 8),
            AuthInputField(
              controller: _nameController,
              label: 'Name',
              hintText: 'Enter your name',
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 24),

            // Email (read-only)
            Text('Email', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              enabled: false,
              style: AppTextStyles.inputText.copyWith(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: AppTextStyles.label.copyWith(fontSize: 14),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: (profileState.profile?.verifiedEmail ?? false)
                    ? const Icon(Icons.verified, color: Colors.green, size: 20)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Email cannot be changed',
              style: AppTextStyles.helper.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            // Email Verification Section (only show if not verified)
            if (!(profileState.profile?.verifiedEmail ?? false)) ...[
              const SizedBox(height: 16),
              _buildVerificationSection(
                context: context,
                label: 'Email Verification',
                isVerified: false,
                identifier: _emailController.text,
                otpController: _emailOtpController,
                isOtpSent: _isEmailOtpSent,
                isVerifying: _isEmailVerifying,
                onSendOtp: _handleSendEmailOtp,
                onVerifyOtp: _handleVerifyEmailOtp,
              ),
            ],
            const SizedBox(height: 24),

            // Phone Number (read-only)
            Text('Phone Number', style: AppTextStyles.label),
            const SizedBox(height: 8),
            TextFormField(
              controller: _phoneController,
              enabled: false,
              style: AppTextStyles.inputText.copyWith(color: Colors.grey),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: AppTextStyles.label.copyWith(fontSize: 14),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: (profileState.profile?.verifiedPhone ?? false)
                    ? const Icon(Icons.verified, color: Colors.green, size: 20)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Phone number cannot be changed',
              style: AppTextStyles.helper.copyWith(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            // Phone Verification Section (only show if not verified)
            if (!(profileState.profile?.verifiedPhone ?? false)) ...[
              const SizedBox(height: 16),
              _buildVerificationSection(
                context: context,
                label: 'Phone Verification',
                isVerified: false,
                identifier: _phoneController.text,
                otpController: _phoneOtpController,
                isOtpSent: _isPhoneOtpSent,
                isVerifying: _isPhoneVerifying,
                onSendOtp: _handleSendPhoneOtp,
                onVerifyOtp: _handleVerifyPhoneOtp,
              ),
            ],
            const SizedBox(height: 32),

            // Error message
            if (_error != null) ...[
              ErrorMessageWidget(message: _error!),
              const SizedBox(height: 16),
            ],

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text('Save Changes', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection({
    required BuildContext context,
    required String label,
    required bool isVerified,
    required String identifier,
    required TextEditingController otpController,
    required bool isOtpSent,
    required bool isVerifying,
    required VoidCallback onSendOtp,
    required VoidCallback onVerifyOtp,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.cardTitle),
              Row(
                children: [
                  Icon(
                    isVerified ? Icons.check_circle : Icons.cancel,
                    color: isVerified ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isVerified ? 'Verified' : 'Not Verified',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isVerified ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 16),
            if (!isOtpSent)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isVerifying ? null : onSendOtp,
                  icon: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(isVerifying ? 'Sending...' : 'Send OTP'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else ...[
              AuthInputField(
                controller: otpController,
                label: 'Enter OTP',
                hintText: 'Enter 6-digit OTP',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isVerifying ? null : onVerifyOtp,
                  icon: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.verified, size: 18),
                  label: Text(isVerifying ? 'Verifying...' : 'Verify OTP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
