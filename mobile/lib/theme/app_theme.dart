import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  /// 瑞士曜黑深色主题 (Swiss Dark: 纯粹深黑 + 极高对比纯白 + 瑞士精准红点睛)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.swissDarkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.swissRedBright,
        secondary: AppColors.swissRed,
        surface: AppColors.swissDarkSurface,
        error: AppColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.swissDarkTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          fontFamily: 'monospace',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.swissDarkSurface,
        selectedItemColor: AppColors.swissRedBright,
        unselectedItemColor: AppColors.swissDarkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.swissDarkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.swissDarkBorder, width: 0.9),
        ),
        elevation: 0,
      ),
    );
  }

  /// 瑞士冷白浅色主题 (Swiss Light: 经典国际主义白底 + 纯黑高对比 + 瑞士精准红点睛)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.swissLightBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.swissRed,
        secondary: AppColors.swissRedBright,
        surface: AppColors.swissLightSurface,
        error: AppColors.rose,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.swissLightTextPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          fontFamily: 'monospace',
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.swissLightSurface,
        selectedItemColor: AppColors.swissRed,
        unselectedItemColor: AppColors.swissLightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          fontFamily: 'monospace',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.swissLightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.swissLightBorder, width: 0.9),
        ),
        elevation: 0,
      ),
    );
  }
}

