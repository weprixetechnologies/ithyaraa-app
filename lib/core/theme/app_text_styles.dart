import 'package:flutter/material.dart';

/// Centralized typography system for the app
///
/// Montserrat → Headings & Emphasis
/// Poppins → Body & UI Text
///
/// All fonts are bundled locally - no runtime fetching
class AppTextStyles {
  AppTextStyles._();

  // ==================== Montserrat - Headings & Emphasis ====================

  /// Montserrat Bold (700) - Main titles, App titles
  static TextStyle headingLarge = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// Montserrat SemiBold (600) - Section headings
  static TextStyle headingMedium = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: -0.3,
    height: 1.3,
  );

  /// Montserrat SemiBold (600) - Section titles
  static TextStyle headingSmall = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: -0.2,
    height: 1.3,
  );

  /// Montserrat Bold (700) - Card titles
  static TextStyle cardTitle = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: Colors.black,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Montserrat Bold (700) - Card titles
  static TextStyle profileTitleCards = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Montserrat Medium (500) - Price text (important numbers)
  static TextStyle price = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.2,
  );

  /// Montserrat SemiBold (600) - CTA headings
  static TextStyle ctaHeading = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.3,
  );

  // ==================== Poppins - Body & UI Text ====================

  /// Poppins Regular (400) - Body text
  static TextStyle bodyLarge = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Poppins Regular (400) - Body text medium
  static TextStyle bodyMedium = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Poppins Regular (400) - Body text small
  static TextStyle bodySmall = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Regular (400) - Descriptions
  static TextStyle description = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey.shade600,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Poppins Medium (500) - Form labels
  static TextStyle label = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Regular (400) - Input text
  static TextStyle inputText = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Poppins Regular (400) - Input hint text
  static TextStyle inputHint = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.5,
  );

  /// Poppins Light (300) - Helper / error text
  static TextStyle helper = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Light (300) - Error text
  static TextStyle error = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: Colors.red,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Medium (500) - Button text
  static TextStyle button = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.5,
    height: 1.2,
  );

  /// Poppins Regular (400) - Captions
  static TextStyle caption = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Medium (500) - Link text
  static TextStyle link = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Medium (500) - Skip button text
  static TextStyle skipButton = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Color(0xFFE91E63),
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Regular (400) - Terms and conditions text
  static TextStyle termsText = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Poppins Medium (500) - Terms link text
  static TextStyle termsLink = const TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
    letterSpacing: 0,
    height: 1.4,
  );

  /// Montserrat Bold (700) - OTP input text
  static TextStyle otpInput = const TextStyle(
    fontFamily: 'Montserrat',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Colors.black87,
    letterSpacing: 8,
    height: 1.2,
  );
}
