import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A custom [TextField] with a label above, an optional leading icon,
/// hint text, validation support, and a password visibility toggle.
///
/// Styling is driven by [AppColors] and [AppTextStyles] so it stays
/// consistent with the app theme without any extra setup.
///
/// Example usage:
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   prefixIcon: Icons.email_outlined,
///   controller: _emailController,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.prefixIcon,
    this.controller,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.isPassword = false,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.initialValue,
    this.maxLines = 1,
    this.fillColor,
    this.borderRadius = 12.0,
    this.contentPadding,
  });

  /// Optional label displayed above the text field.
  final String? label;

  /// Placeholder text shown when the field is empty.
  final String hint;

  /// Material icon shown on the left side of the field.
  final IconData? prefixIcon;

  /// Optional controller for the underlying [TextFormField].
  final TextEditingController? controller;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Keyboard type (email, number, etc.).
  final TextInputType? keyboardType;

  /// Action button on the software keyboard.
  final TextInputAction? textInputAction;

  /// When true, text is obscured and a visibility toggle icon is shown.
  final bool isPassword;

  /// Validation function returning an error string or null.
  final String? Function(String?)? validator;

  /// Called on every character change.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the field (keyboard action).
  final ValueChanged<String>? onFieldSubmitted;

  /// Whether the field is interactive.
  final bool enabled;

  /// When true, text cannot be edited but selection is still possible.
  final bool readOnly;

  /// Initial value (uncontrolled mode, when no [controller] is provided).
  final String? initialValue;

  /// Number of text lines. Keep at 1 for single-line fields.
  final int? maxLines;

  /// Background fill color. Defaults to [AppColors.surfaceVariant].
  final Color? fillColor;

  /// Corner radius of the field border.
  final double borderRadius;

  /// Inner padding override.
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.isPassword && widget.maxLines == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          initialValue: widget.initialValue,
          keyboardType: isPasswordField
              ? TextInputType.visiblePassword
              : widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: isPasswordField && _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: isPasswordField ? 1 : widget.maxLines,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: AppTextStyles.bodyMedium.copyWith(
            color: widget.enabled ? AppColors.textPrimary : AppColors.textHint,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            filled: true,
            fillColor: widget.enabled
                ? (widget.fillColor ?? AppColors.surfaceVariant)
                : AppColors.disabled.withOpacity(0.31),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // Leading icon
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.textSecondary,
                    size: 20,
                  )
                : null,
            // Password visibility toggle
            suffixIcon: isPasswordField
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscureText = !_obscureText);
                    },
                  )
                : null,
            // Borders
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide.none,
            ),
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
