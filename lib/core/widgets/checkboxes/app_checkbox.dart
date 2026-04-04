import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucid_state_app/app/theme/app_colors.dart';
import 'package:lucid_state_app/app/theme/app_text_styles.dart';

/// A tappable text span inside [AppCheckbox]'s label.
///
/// Use [AppCheckboxLabelLink] entries in [AppCheckbox.links] to make
/// portions of the label text interactive (e.g., "Terms & Conditions").
class AppCheckboxLabelLink {
  const AppCheckboxLabelLink({
    required this.text,
    required this.onTap,
    this.color = AppColors.primary,
  });

  /// The link text to match inside the full label string.
  final String text;

  /// Callback fired when this link is tapped.
  final VoidCallback onTap;

  /// Color of the link text.
  final Color color;
}

/// A custom checkbox with a rich-text label that can contain inline links.
///
/// Example:
/// ```dart
/// AppCheckbox(
///   value: _agreed,
///   onChanged: (v) => setState(() => _agreed = v ?? false),
///   label: 'I agree to the Terms & Conditions and Privacy Policy',
///   links: [
///     AppCheckboxLabelLink(
///       text: 'Terms & Conditions',
///       onTap: () { /* open terms */ },
///     ),
///     AppCheckboxLabelLink(
///       text: 'Privacy Policy',
///       onTap: () { /* open privacy */ },
///     ),
///   ],
/// )
/// ```
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.links = const [],
    this.activeColor = AppColors.primary,
    this.checkColor = Colors.white,
    this.labelStyle,
    this.errorText,
  });

  /// Current checked state.
  final bool value;

  /// Called when the checked state changes.
  final ValueChanged<bool?>? onChanged;

  /// Full label text displayed next to the checkbox.
  final String label;

  /// List of tappable sub-strings within [label].
  final List<AppCheckboxLabelLink> links;

  /// Fill color of the checkbox when checked.
  final Color activeColor;

  /// Color of the checkmark icon.
  final Color checkColor;

  /// Override for the label text style.
  final TextStyle? labelStyle;

  /// Optional validation error text shown below the checkbox.
  final String? errorText;

  /// Builds a [TextSpan] tree from [label], replacing every occurrence of each
  /// [links] entry's text with a tappable span.
  ///
  /// Occurrences are processed left-to-right so overlapping patterns are
  /// handled gracefully.
  List<TextSpan> _buildSpans(TextStyle baseStyle) {
    if (links.isEmpty) {
      return [TextSpan(text: label, style: baseStyle)];
    }

    // Build a sorted list of (startIndex, link) for all occurrences of every
    // link text within [label], then iterate in order.
    final matches = <({int start, int end, AppCheckboxLabelLink link})>[];
    for (final link in links) {
      int searchFrom = 0;
      while (true) {
        final idx = label.indexOf(link.text, searchFrom);
        if (idx == -1) break;
        matches.add((start: idx, end: idx + link.text.length, link: link));
        searchFrom = idx + link.text.length;
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    if (matches.isEmpty) {
      return [TextSpan(text: label, style: baseStyle)];
    }

    final spans = <TextSpan>[];
    int cursor = 0;

    for (final m in matches) {
      // Skip overlapping matches
      if (m.start < cursor) continue;

      if (m.start > cursor) {
        spans.add(TextSpan(
          text: label.substring(cursor, m.start),
          style: baseStyle,
        ));
      }

      spans.add(
        TextSpan(
          text: label.substring(m.start, m.end),
          style: baseStyle.copyWith(
            color: m.link.color,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: m.link.color,
          ),
          recognizer: TapGestureRecognizer()..onTap = m.link.onTap,
        ),
      );

      cursor = m.end;
    }

    if (cursor < label.length) {
      spans.add(TextSpan(text: label.substring(cursor), style: baseStyle));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = (labelStyle ?? AppTextStyles.bodyMedium).copyWith(
      color: AppColors.textPrimary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: activeColor,
                checkColor: checkColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: RichText(
                  text: TextSpan(children: _buildSpans(baseStyle)),
                ),
              ),
            ),
          ],
        ),
        if (errorText != null && errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 34),
            child: Text(
              errorText!,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
