import 'package:flutter/material.dart';

class AppColors {
  static const Color bgMain = Color(0xFF18181C);
  static const Color bgCard = Color(0xFF232329);
  static const Color bgModal = Color(0xFF1E1E24);
  static const Color bgInput = Color(0xFF27272F);
  static const Color bgNav = Color(0xFF222228);

  static const Color primaryNavy = Color(0xFF1E2856);
  static const Color brandNavy = Color(0xFF1B2A6B);
  static const Color successGreen = Color(0xFF15803D);
  static const Color warningAmber = Color(0xFFB45309);

  static Color get borderSubtle => Colors.white.withValues(alpha: 0.12);
  static Color get borderMedium => Colors.white.withValues(alpha: 0.16);
  static Color get borderStrong => Colors.white.withValues(alpha: 0.22);
  static Color get borderFocused => Colors.white.withValues(alpha: 0.35);

  static BoxDecoration modalSheetDecoration() {
    return BoxDecoration(
      color: bgModal,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      border: Border(
        top: BorderSide(color: borderMedium, width: 1.0),
        left: BorderSide(color: borderMedium, width: 1.0),
        right: BorderSide(color: borderMedium, width: 1.0),
      ),
    );
  }

  static InputDecoration darkInputDecoration({
    String? labelText,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70, size: 20) : null,
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderSubtle, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderSubtle, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderFocused, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}
