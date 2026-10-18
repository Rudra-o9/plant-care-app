import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Centralized ThemeData for Plant Care application.
class AppTheme {
  static ThemeData get lightTheme {
    return _buildTheme(
      const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      Brightness.light,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      const ColorScheme.dark(
        primary: AppColors.secondary,
        onPrimary: Color(0xFF062218),
        secondary: AppColors.accentGold,
        onSecondary: Color(0xFF241B06),
        surface: Color(0xFF18251F),
        onSurface: Color(0xFFE7F1EB),
        error: Color(0xFFFF8A8A),
        onError: Color(0xFF351010),
      ),
      Brightness.dark,
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF2D4036) : AppColors.border;
    final subtleSurface = isDark ? const Color(0xFF21332A) : AppColors.surfaceSubtle;
    final mutedText = isDark ? const Color(0xFFAABDB2) : AppColors.textSecondary;
    final lightText = isDark ? const Color(0xFF789087) : AppColors.textLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: isDark ? const Color(0xFF101A16) : AppColors.background,
      primaryColor: scheme.primary,
      colorScheme: scheme,

      // System Bar Overlay Setup
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: scheme.onSurface),
        titleTextStyle: AppTextStyles.headlineMedium.copyWith(color: scheme.onSurface),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
      ),

      // Card Theme with Soft Shadows and Rounded Corners
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          minimumSize: const Size(double.infinity, 54),
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.button.copyWith(color: scheme.primary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: AppTextStyles.titleMedium,
        ),
      ),

      // Input Decoration Theme for Forms
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: lightText),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.secondary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: subtleSurface,
        selectedColor: scheme.primary,
        disabledColor: isDark ? const Color(0xFF2A3931) : Colors.grey.shade200,
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: lightText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
