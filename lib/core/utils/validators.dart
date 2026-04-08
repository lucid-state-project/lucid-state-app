/// Centralized form validation utilities.
///
/// Provides consistent validation patterns across the app for email,
/// password, and other form fields.
class Validators {
  const Validators._();

  /// Email validation pattern - RFC 5322 simplified
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  /// Password minimum length requirement
  static const int minPasswordLength = 6;

  /// Validates email address format.
  ///
  /// Returns error message if invalid, null if valid.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final regex = RegExp(emailPattern);
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password strength and length.
  ///
  /// Returns error message if invalid, null if valid.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }

    return null;
  }

  /// Validates that password and confirmation match.
  ///
  /// Returns error message if they don't match, null if valid.
  static String? validatePasswordConfirmation(
    String? password,
    String? confirmation,
  ) {
    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Generic validation for non-empty text fields.
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }
}
