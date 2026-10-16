import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra Clean FinTech & Minimalist Palette (inspired by Reference UI)
  static const Color bgLight = Color(0xFFF7F8FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16161C);
  static const Color cardSurface = Color(0xFFF2F4F7);
  
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderSubtle = Color(0xFFEFF0F3);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Reference UI Donut & Status Accents
  static const Color accentGreen = Color(0xFF5DE2A5);   // Mint available
  static const Color accentPink = Color(0xFFFF9BA9);    // Soft coral/bonds
  static const Color accentYellow = Color(0xFFFFCC66);  // Warm yellow spent
  static const Color accentDark = Color(0xFF111827);

  static ThemeData get theme {
    final fontName = GoogleFonts.mali().fontFamily;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontName,
      scaffoldBackgroundColor: bgLight,
      primaryColor: accentDark,
      colorScheme: const ColorScheme.light(
        surface: surfaceWhite,
        primary: accentDark,
        secondary: textSecondary,
        error: accentPink,
        outline: borderLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.mali(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textPrimary, size: 20),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        elevation: 0,
        height: 68,
        indicatorColor: accentDark,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.mali(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            );
          }
          return GoogleFonts.mali(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 22);
          }
          return const IconThemeData(color: textMuted, size: 22);
        }),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceWhite,
        modalBackgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
      ),
    );
  }
}
