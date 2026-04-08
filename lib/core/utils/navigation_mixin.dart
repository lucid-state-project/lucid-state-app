import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucid_state_app/core/services/timer_service.dart';

/// Mixin that provides common navigation patterns.
///
/// Use this mixin in page states to handle navigation animations
/// and loading states consistently across the app.
mixin NavigationMixin<T extends StatefulWidget> on State<T> {
  /// Navigates to the specified route with a loading animation.
  ///
  /// Shows a loading state with optional delay, then performs the navigation.
  /// Automatically manages the visibility of the timer overlay during transition.
  ///
  /// Example:
  /// ```dart
  /// await navigateWithLoading(
  ///   () => context.go('/home'),
  ///   duration: Duration(milliseconds: 350),
  /// );
  /// ```
  Future<void> navigateWithLoading(
    VoidCallback onNavigate, {
    Duration duration = const Duration(milliseconds: 350),
  }) async {
    try {
      // Show loading overlay
      if (mounted) {
        context.read<TimerService>().showOverlay();
      }

      // Wait for transition animation
      await Future.delayed(duration);

      // Navigate
      onNavigate();
    } finally {
      // Hide loading overlay
      if (mounted) {
        context.read<TimerService>().hideOverlay();
      }
    }
  }

  /// Shows a snackbar with the given message.
  ///
  /// Optionally configure duration, action, and background color.
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Shows an error snackbar with red background.
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red[600],
    );
  }

  /// Shows a success snackbar with green background.
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green[600],
    );
  }
}
