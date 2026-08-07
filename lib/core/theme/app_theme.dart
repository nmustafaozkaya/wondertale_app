import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Magical Light Color Palette ────────────────────────────────────────────
  static const Color bgLight       = Color(0xFFF8F9FE); // Very soft blue/white
  static const Color bgCard        = Color(0xFFFFFFFF); // Pure white card
  static const Color violet        = Color(0xFF8B5CF6); // Soft bright violet
  static const Color purple        = Color(0xFFC084FC); // Soft purple
  static const Color pink          = Color(0xFFF472B6); // Pastel pink
  static const Color gold          = Color(0xFFFBBF24); // Warm gold
  static const Color teal          = Color(0xFF2DD4BF); // Bright teal
  
  // Text Colors
  static const Color textPrimary   = Color(0xFF1E1B4B); // Deep indigo for contrast
  static const Color textSecondary = Color(0xFF6B7280); // Soft grey
  static const Color textLight     = Color(0xFF9CA3AF); // Lighter grey

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFC084FC), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFFF8F9FE), Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE68A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass card decoration (Light)
  static BoxDecoration glassCard({
    Color borderColor = const Color(0x338B5CF6),
    double borderWidth = 1.5,
    double radius = 24,
    Color? bgColor,
  }) => BoxDecoration(
    color: bgColor ?? const Color(0xFFFFFFFF).withValues(alpha: 0.85),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Glowing gradient button decoration (Light)
  static BoxDecoration glowButton({double radius = 18}) => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // ── Theme Data ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = GoogleFonts.outfitTextTheme(ThemeData.light().textTheme);

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgLight,
      primaryColor: violet,
      colorScheme: const ColorScheme.light(
        primary: violet,
        secondary: gold,
        surface: bgCard,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shadowColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: violet,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: violet.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: violet.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: violet, width: 2),
        ),
      ),
      textTheme: base.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 36, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 22, fontWeight: FontWeight.w700, color: textPrimary,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          fontSize: 16, height: 1.65, color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          fontSize: 14, color: textSecondary,
        ),
        labelLarge: GoogleFonts.outfit(
          fontSize: 15, fontWeight: FontWeight.w600, color: textPrimary,
        ),
      ),
    );
  }
}
