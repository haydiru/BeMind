import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Light Colors (Matching Design Reference Image)
  static const Color background = Color(0FFF4F7FC); // Soft bluish-gray background
  static const Color surface = Color(0FFFFFFFF); // Crisp white card surface
  static const Color surfaceElevated = Color(0FFF8FAFC);
  static const Color surfaceLight = Color(0FFEBF5FF); // Light blue tint
  static const Color surfaceBorder = Color(0FFE2E8F0);

  // Vibrant Gradients & Accent Colors
  static const Color primaryCyan = Color(0FF00E5FF);
  static const Color primaryPurple = Color(0FF9333EA);
  static const Color primaryBlue = Color(0FF007AFF);
  static const Color accentEmerald = Color(0FF16A34A);
  static const Color accentRose = Color(0FFFF3366);
  static const Color accentOrange = Color(0FFEA580C);

  // Colorful Chip Backgrounds (Source Integration)
  static const Color chipTextBg = Color(0FFEBF5FF);
  static const Color chipTextColor = Color(0FF007AFF);
  static const Color chipVoiceBg = Color(0FFF3E8FF);
  static const Color chipVoiceColor = Color(0FF9333EA);
  static const Color chipPdfBg = Color(0FFDCFCE7);
  static const Color chipPdfColor = Color(0FF16A34A);
  static const Color chipOcrBg = Color(0FFFFEDD5);
  static const Color chipOcrColor = Color(0FFEA580C);

  // Text Colors
  static const Color textPrimary = Color(0FF0F172A);
  static const Color textSecondary = Color(0FF64748B);
  static const Color textMuted = Color(0FF94A3B8);

  // Signature Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryCyan, primaryBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0FF00C6FF), Color(0FF9B51E0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient playButtonGradient = LinearGradient(
    colors: [Color(0FFFF3366), Color(0FFFF5E62)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: primaryPurple,
        surface: surface,
        background: background,
        error: accentRose,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background.withOpacity(0.95),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 16, height: 1.5),
        bodyMedium: GoogleFonts.plusJakartaSans(color: textSecondary, fontSize: 14, height: 1.4),
        labelLarge: GoogleFonts.plusJakartaSans(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
    );
  }

  // Card Box Decoration
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      color: color ?? surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? surfaceBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0FF0F172A).withOpacity(0.03),
          blurRadius: 30,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Alias methods for full backward compatibility
  static BoxDecoration glassDecoration({Color? color, Color? borderColor, double borderRadius = 24}) {
    return cardDecoration(color: color, borderColor: borderColor, borderRadius: borderRadius);
  }

  static BoxDecoration neonDecoration({required List<Color> gradientColors, double borderRadius = 24}) {
    return BoxDecoration(
      gradient: LinearGradient(colors: gradientColors),
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: gradientColors.first.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration gradientButtonDecoration({double borderRadius = 24}) {
    return BoxDecoration(
      gradient: buttonGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: primaryPurple.withOpacity(0.32),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
