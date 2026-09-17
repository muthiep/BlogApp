import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Colors.white;
  static const Color primary = Color(0xFF4A4A4A);
  static const Color primaryLight = Color(0xFFE8E7FF);
  static const Color chipBackground = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF10B981);
}

class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle meta = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.7,
    color: AppColors.textPrimary,
  );
}

InputDecoration appInputDecoration({
  required String label,
  String? hint,
  IconData? icon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    prefixIcon: icon == null
        ? null
        : Icon(icon, color: AppColors.textSecondary),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.chipBackground),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.chipBackground),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
  );
}

