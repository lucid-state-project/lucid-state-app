import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String _fontFamily = 'PlusJakartaSans';

  // Headings
  static const TextStyle heading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  // Headings
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

    static const TextStyle heading2Italic = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Button
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0.5,
  );
}