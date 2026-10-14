import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════
  // LIGHT CANVAS — Island Clean White & Luminous Surfaces
  // ═══════════════════════════════════════════════════════
  static const Color bgLight = Color(0xFFF8F9FF);      // Pure canvas ice white
  static const Color bgSurface = Color(0xFFFFFFFF);    // Pure white card
  static const Color bgCard = Color(0xFFF1F4FF);       // Soft violet-white tint
  static const Color bgSubtle = Color(0xFFEEF2FF);     // Subtle glass panel
  // Keep for backward compat (some widgets still use bgDark)
  static const Color bgDark = Color(0xFFF8F9FF);

  // ═══════════════════════════════════════════════════════
  // BRAND — Politeknik Negeri Lhokseumawe (PNL)
  // ═══════════════════════════════════════════════════════
  static const Color pnlPrimary = Color(0xFF1D6FF2);     // Vivid Royal Blue
  static const Color pnlCyanGlow = Color(0xFF06B6D4);    // Cyan Teal
  static const Color pnlGold = Color(0xFFF59E0B);        // Amber 500
  static const Color pnlGoldLight = Color(0xFFFDE68A);   // Amber 200
  static const Color emeraldVerified = Color(0xFF059669); // Emerald 600
  static const Color roseWarning = Color(0xFFE11D48);    // Rose 600

  // ═══════════════════════════════════════════════════════
  // 6 JURUSAN PNL — Vivid & Saturated on White
  // ═══════════════════════════════════════════════════════
  static const Color jurusanSipil     = Color(0xFF2563EB); // 🔵 Biru – Teknik Sipil
  static const Color jurusanMesin     = Color(0xFFEF4444); // 🔴 Merah – Teknik Mesin
  static const Color jurusanKimia     = Color(0xFFF97316); // 🟠 Orange – Teknik Kimia
  static const Color jurusanTataNiaga = Color(0xFFA855F7); // 🟣 Ungu – Tata Niaga
  static const Color jurusanTIK       = Color(0xFFD97706); // 🟤 Amber-Coklat – TIK
  static const Color jurusanElektro   = Color(0xFF10B981); // 🟢 Hijau – Teknik Elektro

  // ═══════════════════════════════════════════════════════
  // PNL SIGNATURE & ISLAND CLEAN
  // ═══════════════════════════════════════════════════════
  static const Color pnlSignatureGold  = Color(0xFFFFB300); // 🟡 Kuning Emas Utama PNL
  static const Color islandCleanWhite  = Color(0xFFFFFFFF); // ⚪ Island Pure White
  static const Color islandSurfaceLight = Color(0x18FFFFFF); // Translucent specular

  // ═══════════════════════════════════════════════════════
  // GLASS SYSTEM — Light-Mode Frosted Glass Values
  // ═══════════════════════════════════════════════════════
  static const Color glassWhite    = Color(0xCCFFFFFF); // 80% white frosted
  static const Color glassSpecular = Color(0xFFFFFFFF); // pure specular
  static const Color glassBorder   = Color(0x28000000); // subtle dark border
  static const Color glassGlow     = Color(0x1A1D6FF2); // Blue ambient

  // ═══════════════════════════════════════════════════════
  // TYPOGRAPHY — Dark text on white canvas
  // ═══════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF0F172A);  // Near-black slate
  static const Color textLight   = Color(0xFF1E293B);  // Slate 800
  static const Color textMuted   = Color(0xFF64748B);  // Slate 500
  static const Color textDim     = Color(0xFF94A3B8);  // Slate 400
  static const Color textOnColor = Color(0xFFFFFFFF);  // White on colored BG
}

class AppTheme {
  static ThemeData get darkTheme {
    // Despite the name "darkTheme" (kept for backward compat), this is now Light
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.pnlPrimary,
        secondary: AppColors.pnlGold,
        surface: AppColors.bgSurface,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
    );
  }
}
