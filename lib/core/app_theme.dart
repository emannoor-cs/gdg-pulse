import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Provides [ThemeData] for both light and dark modes.
///
/// Usage in [MaterialApp]:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
///
/// Design decisions:
/// • Material 3 is enabled so widgets like [NavigationBar], [FilledButton],
///   and [CardTheme] render with the correct M3 shapes and elevations.
/// • Every component theme is declared explicitly so no default leaks through.
/// • Radius constants mirror the prototype CSS variables:
///     --radius: 16px, --radius-md: 12px, --radius-sm: 8px
abstract final class AppTheme {
  // ─────────────────────────────────────────────
  // Radius Constants  (mirrors CSS vars in prototype)
  // ─────────────────────────────────────────────

  static const double radiusLg = 16;
  static const double radiusMd = 12;
  static const double radiusSm = 8;

  // ─────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────

  static ThemeData get light => _build(isDark: false);

  // ─────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────

  static ThemeData get dark => _build(isDark: true);

  // ─────────────────────────────────────────────
  // Internal Builder
  // ─────────────────────────────────────────────

  static ThemeData _build({required bool isDark}) {
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,

      // ── Scaffold ──────────────────────────────
      scaffoldBackgroundColor:
          isDark ? AppColors.darkSurface : AppColors.surface2,

      // ── Typography ────────────────────────────
      fontFamily: 'Roboto',
      textTheme: _buildTextTheme(isDark),

      // ── App Bar ───────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.darkSurface2 : AppColors.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      // ── Card ──────────────────────────────────
      cardTheme: CardTheme(
        color: isDark ? AppColors.darkSurface2 : AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Elevated Button ───────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gdgBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.gdgBlue.withOpacity(0.4),
          disabledForegroundColor: Colors.white60,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gdgBlue,
          side: const BorderSide(color: AppColors.gdgBlue, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ───────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gdgBlue,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Input / Text Field ────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface3 : AppColors.surface3,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          fontSize: 15,
        ),
        // All four border states are set to avoid M3 default outline bleed
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide:
              const BorderSide(color: AppColors.gdgBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide:
              const BorderSide(color: AppColors.gdgRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide:
              const BorderSide(color: AppColors.gdgRed, width: 2),
        ),
      ),

      // ── Dropdown ──────────────────────────────
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? AppColors.darkSurface3 : AppColors.surface3,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusMd),
            borderSide:
                const BorderSide(color: AppColors.gdgBlue, width: 1.5),
          ),
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface2 : AppColors.surface,
        elevation: 0,
        selectedItemColor: AppColors.gdgBlue,
        unselectedItemColor: isDark
            ? AppColors.darkTextTertiary
            : AppColors.textTertiary,
        selectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(
            fontSize: 10, fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ── Tab Bar ───────────────────────────────
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.gdgBlue,
        unselectedLabelColor:
            isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        indicatorColor: AppColors.gdgBlue,
        dividerColor:
            isDark ? AppColors.borderDark : AppColors.border,
        labelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // ── Chip ──────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface3 : AppColors.surface,
        side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: const StadiumBorder(),
      ),

      // ── Floating Action Button ─────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gdgBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ── List Tile ─────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        subtitleTextStyle: const TextStyle(
            fontSize: 12, color: AppColors.textSecondary),
        minLeadingWidth: 0,
      ),

      // ── Divider ───────────────────────────────
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.border,
        thickness: 0.5,
        space: 0,
      ),

      // ── Dialog / Bottom Sheet ─────────────────
      dialogTheme: DialogTheme(
        backgroundColor:
            isDark ? AppColors.darkSurface2 : AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLg)),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
        elevation: 3,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface2 : AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(radiusLg + 4)),
        ),
        elevation: 8,
        modalElevation: 8,
      ),

      // ── Progress Indicator ────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gdgBlue,
        linearTrackColor: AppColors.surface3,
        linearMinHeight: 6,
        circularTrackColor: AppColors.surface3,
      ),

      // ── Switch ────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gdgBlue;
          }
          return isDark ? AppColors.darkTextTertiary : AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gdgBlueLight;
          }
          return isDark ? AppColors.darkSurface3 : AppColors.surface3;
        }),
      ),

      // ── Snack Bar ─────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            isDark ? AppColors.darkSurface3 : AppColors.textPrimary,
        contentTextStyle: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
        actionTextColor: AppColors.gdgYellow,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Color Schemes
  // ─────────────────────────────────────────────

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.gdgBlue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.gdgBlueLight,
    onPrimaryContainer: AppColors.gdgBlueDark,
    secondary: AppColors.gdgRed,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.gdgRedLight,
    onSecondaryContainer: AppColors.gdgRedDark,
    tertiary: AppColors.gdgGreen,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.gdgGreenLight,
    onTertiaryContainer: AppColors.gdgGreenDark,
    error: AppColors.gdgRed,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.surface,
    surfaceContainerLow: AppColors.surface2,
    surfaceContainer: AppColors.surface3,
    outline: AppColors.border,
    outlineVariant: AppColors.border,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.gdgBlue,
    onPrimary: Colors.white,
    primaryContainer: AppColors.gdgBlueDark,
    onPrimaryContainer: AppColors.gdgBlueLight,
    secondary: AppColors.gdgRed,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF7A1A14),
    onSecondaryContainer: AppColors.gdgRedLight,
    tertiary: AppColors.gdgGreen,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF1A4A28),
    onTertiaryContainer: AppColors.gdgGreenLight,
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF690005),
    surface: AppColors.darkSurface2,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerLowest: AppColors.darkSurface,
    surfaceContainerLow: AppColors.darkSurface2,
    surfaceContainer: AppColors.darkSurface3,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark,
  );

  // ─────────────────────────────────────────────
  // Text Theme
  // ─────────────────────────────────────────────

  static TextTheme _buildTextTheme(bool isDark) {
    final baseColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return TextTheme(
      // Display styles — large splashes, onboarding
      displayLarge: TextStyle(
          fontSize: 57, fontWeight: FontWeight.w400, color: baseColor),
      displayMedium: TextStyle(
          fontSize: 45, fontWeight: FontWeight.w400, color: baseColor),
      displaySmall: TextStyle(
          fontSize: 36, fontWeight: FontWeight.w400, color: baseColor),
      // Headline styles — screen titles, section headers
      headlineLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: baseColor),
      headlineMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: baseColor),
      headlineSmall: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: baseColor),
      // Title styles — card titles, app bar
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: baseColor),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: baseColor),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      // Body styles — paragraphs, list items
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: baseColor),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: baseColor),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: secondaryColor),
      // Label styles — buttons, chips, captions
      labelLarge: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: baseColor),
      labelSmall: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w500, color: secondaryColor),
    );
  }
}
