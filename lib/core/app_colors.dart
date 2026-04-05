import 'package:flutter/material.dart';

/// Central color palette for GDG Pulse.
///
/// All color values are taken directly from the HTML prototype's CSS variables
/// so screens match the design 1-to-1. Organised into:
///   • GDG brand primaries
///   • Light (tint) variants used for chip/badge backgrounds
///   • Dark (shade) variants used for pressed states and dark-mode surfaces
///   • Neutral surfaces (white → light-grey hierarchy)
///   • Semantic text hierarchy (primary → secondary → tertiary)
///   • Utility (border, shadow, overlay)
///   • Gradient presets shared across screens
///   • Avatar palette — deterministic colours per member index
abstract final class AppColors {
  // ─────────────────────────────────────────────
  // GDG Brand Primaries
  // ─────────────────────────────────────────────

  /// #1A73E8  — Google Blue
  static const Color gdgBlue = Color(0xFF1A73E8);

  /// #EA4335  — Google Red
  static const Color gdgRed = Color(0xFFEA4335);

  /// #FBBC04  — Google Yellow
  static const Color gdgYellow = Color(0xFFFBBC04);

  /// #34A853  — Google Green
  static const Color gdgGreen = Color(0xFF34A853);

  /// #9C27B0  — Purple (used for "Excused" attendance status)
  static const Color gdgPurple = Color(0xFF9C27B0);

  // ─────────────────────────────────────────────
  // Light (Tint) Variants  — chip/badge backgrounds
  // ─────────────────────────────────────────────

  /// #E8F0FE  — Blue tint (12 % opacity on white)
  static const Color gdgBlueLight = Color(0xFFE8F0FE);

  /// #FCE8E6  — Red tint
  static const Color gdgRedLight = Color(0xFFFCE8E6);

  /// #FEF9E7  — Yellow tint
  static const Color gdgYellowLight = Color(0xFFFEF9E7);

  /// #E6F4EA  — Green tint
  static const Color gdgGreenLight = Color(0xFFE6F4EA);

  /// #F3E5F5  — Purple tint
  static const Color gdgPurpleLight = Color(0xFFF3E5F5);

  // ─────────────────────────────────────────────
  // Dark (Shade) Variants  — pressed states, dark-mode accents
  // ─────────────────────────────────────────────

  /// #0052CC  — Darker blue (used in Quiz header gradient)
  static const Color gdgBlueDark = Color(0xFF0052CC);

  /// #C5221F  — Darker red (wrong-answer text)
  static const Color gdgRedDark = Color(0xFFC5221F);

  /// #8A6500  — Darker yellow/amber (text on yellow chips)
  static const Color gdgYellowDark = Color(0xFF8A6500);

  /// #5F4700  — Deep amber (text on yellow event badges)
  static const Color gdgYellowDeep = Color(0xFF5F4700);

  /// #1B6B35  — Darker green (correct-answer text)
  static const Color gdgGreenDark = Color(0xFF1B6B35);

  // ─────────────────────────────────────────────
  // Neutral Surfaces  (light theme)
  // ─────────────────────────────────────────────

  /// #FFFFFF  — Cards, bottom nav, modal sheets
  static const Color surface = Color(0xFFFFFFFF);

  /// #F8F9FA  — Scaffold / page background
  static const Color surface2 = Color(0xFFF8F9FA);

  /// #F1F3F4  — Input fields, secondary card fill, legend background
  static const Color surface3 = Color(0xFFF1F3F4);

  // ─────────────────────────────────────────────
  // Neutral Surfaces  (dark theme)
  // ─────────────────────────────────────────────

  /// #121212  — Dark scaffold background
  static const Color darkSurface = Color(0xFF121212);

  /// #1E1E1E  — Dark card background
  static const Color darkSurface2 = Color(0xFF1E1E1E);

  /// #2C2C2C  — Dark input / secondary fill
  static const Color darkSurface3 = Color(0xFF2C2C2C);

  // ─────────────────────────────────────────────
  // Text Hierarchy  (light theme)
  // ─────────────────────────────────────────────

  /// #202124  — Headlines, card titles, body copy
  static const Color textPrimary = Color(0xFF202124);

  /// #5F6368  — Subtitles, secondary labels, description text
  static const Color textSecondary = Color(0xFF5F6368);

  /// #9AA0A6  — Captions, timestamps, placeholder hints
  static const Color textTertiary = Color(0xFF9AA0A6);

  // ─────────────────────────────────────────────
  // Text Hierarchy  (dark theme)
  // ─────────────────────────────────────────────

  /// #E8EAED  — Dark primary text
  static const Color darkTextPrimary = Color(0xFFE8EAED);

  /// #9AA0A6  — Dark secondary text (same as light tertiary — intentional)
  static const Color darkTextSecondary = Color(0xFF9AA0A6);

  /// #5F6368  — Dark tertiary text
  static const Color darkTextTertiary = Color(0xFF5F6368);

  // ─────────────────────────────────────────────
  // Utility
  // ─────────────────────────────────────────────

  /// 12 % black  — divider lines, card outlines, input borders
  static const Color border = Color(0x1F000000);

  /// 8 % black  — divider in dark contexts
  static const Color borderDark = Color(0x14FFFFFF);

  /// Transparent helper — avoids magic `Colors.transparent` literals
  static const Color transparent = Color(0x00000000);

  // ─────────────────────────────────────────────
  // Status / Semantic
  // ─────────────────────────────────────────────

  /// Attendance: Present
  static const Color statusPresent = gdgGreen;

  /// Attendance: Late
  static const Color statusLate = gdgYellow;

  /// Attendance: Absent
  static const Color statusAbsent = gdgRed;

  /// Attendance: Excused
  static const Color statusExcused = gdgPurple;

  /// Attendance: Unset / Unknown
  static const Color statusUnset = Color(0xFF9E9E9E);

  // ─────────────────────────────────────────────
  // Gradient Presets  — shared across Event cards, profile header, quiz header
  // ─────────────────────────────────────────────

  /// Blue → Red  (Google I/O Extended feature banner)
  static const Gradient gradientBlueRed = LinearGradient(
    colors: [gdgBlue, gdgRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue → Green  (Flutter Workshop card)
  static const Gradient gradientBlueGreen = LinearGradient(
    colors: [gdgBlue, gdgGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Red → Yellow  (ML Model Deployment card)
  static const Gradient gradientRedYellow = LinearGradient(
    colors: [gdgRed, gdgYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green → Blue  (Cloud Summit card)
  static const Gradient gradientGreenBlue = LinearGradient(
    colors: [gdgGreen, gdgBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue → Deep Blue  (Dashboard header, Quiz header)
  static const Gradient gradientBlueDark = LinearGradient(
    colors: [gdgBlue, gdgBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Blue → Blue-Light  (Profile hero header)
  static const Gradient gradientProfileHero = LinearGradient(
    colors: [gdgBlue, gdgBlueLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Card image overlay — transparent → black 70 %  (event banner scrim)
  static const Gradient gradientScrim = LinearGradient(
    colors: [transparent, Color(0xB3000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─────────────────────────────────────────────
  // Avatar Palette  — cycle through these for member initials
  // ─────────────────────────────────────────────

  /// 8-colour cycling palette; use `avatarColor(index)` to pick one.
  static const List<Color> _avatarPalette = [
    gdgBlue,
    gdgRed,
    gdgGreen,
    gdgPurple,
    Color(0xFFFF6D00), // Deep Orange
    Color(0xFF00897B), // Teal
    Color(0xFF6D4C41), // Brown
    Color(0xFF546E7A), // Blue Grey
  ];

  /// Returns a deterministic avatar background colour for the given [index].
  static Color avatarColor(int index) =>
      _avatarPalette[index % _avatarPalette.length];

  // ─────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────

  /// Returns the matching light-tint colour for a given GDG primary.
  /// Falls back to [gdgBlueLight] for unrecognised inputs.
  static Color lightVariant(Color primary) {
    if (primary == gdgBlue) return gdgBlueLight;
    if (primary == gdgRed) return gdgRedLight;
    if (primary == gdgYellow) return gdgYellowLight;
    if (primary == gdgGreen) return gdgGreenLight;
    if (primary == gdgPurple) return gdgPurpleLight;
    return gdgBlueLight;
  }

  /// Returns the matching dark text colour for label-on-tint scenarios.
  static Color darkVariant(Color primary) {
    if (primary == gdgBlue) return gdgBlue;
    if (primary == gdgRed) return gdgRedDark;
    if (primary == gdgYellow) return gdgYellowDark;
    if (primary == gdgGreen) return gdgGreenDark;
    if (primary == gdgPurple) return gdgPurple;
    return gdgBlue;
  }
}
