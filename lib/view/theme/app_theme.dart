import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens do DESIGN.md (TrackMod Design System) convertidos para Flutter.
class AppColors {
  static const surface = Color(0xFF131313);
  static const surfaceContainerLow = Color(0xFF1C1B1B);
  static const surfaceContainer = Color(0xFF201F1F);
  static const surfaceContainerHigh = Color(0xFF2A2A2A);
  static const surfaceContainerHighest = Color(0xFF353534);
  static const onSurface = Color(0xFFE5E2E1);
  static const onSurfaceVariant = Color(0xFFE4BEBC);
  static const outlineVariant = Color(0xFF5B403F);

  static const primary = Color(0xFFFFB3B1);
  static const onPrimary = Color(0xFF680011);
  static const racingRed = Color(0xFFE63946); // botão principal
  static const performanceBlue = Color(0xFF457B9D); // botão secundário
  static const secondary = Color(0xFF98CDF2);
  static const secondaryContainer = Color(0xFF0B4E6E);
  static const tertiary = Color(0xFF9ECFD1);
  static const tertiaryContainer = Color(0xFF68999B);
  static const error = Color(0xFFFFB4AB);

  // Versões translúcidas (ARGB) para evitar withOpacity/withValues
  static const racingRed20 = Color(0x33E63946);
  static const secondary20 = Color(0x3398CDF2);
}

/// Estilos de texto reaproveitáveis.
/// Inter = textos; JetBrains Mono = labels, números e "telemetria".
class AppText {
  static TextStyle label({double size = 14, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.7,
        color: color ?? AppColors.onSurfaceVariant,
      );

  static TextStyle headline({double size = 24, Color? color}) => GoogleFonts.inter(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.onSurface,
      );

  static TextStyle body({double size = 16, Color? color}) => GoogleFonts.inter(
        fontSize: size,
        color: color ?? AppColors.onSurface,
      );
}

class AppTheme {
  /// Aplica a fonte Inter em cada estilo do TextTheme base.
  static TextTheme _textThemeInter(TextTheme t) {
    TextStyle? inter(TextStyle? estilo) => GoogleFonts.inter(textStyle: estilo);
    return TextTheme(
      displayLarge: inter(t.displayLarge),
      displayMedium: inter(t.displayMedium),
      displaySmall: inter(t.displaySmall),
      headlineLarge: inter(t.headlineLarge),
      headlineMedium: inter(t.headlineMedium),
      headlineSmall: inter(t.headlineSmall),
      titleLarge: inter(t.titleLarge),
      titleMedium: inter(t.titleMedium),
      titleSmall: inter(t.titleSmall),
      bodyLarge: inter(t.bodyLarge),
      bodyMedium: inter(t.bodyMedium),
      bodySmall: inter(t.bodySmall),
      labelLarge: inter(t.labelLarge),
      labelMedium: inter(t.labelMedium),
      labelSmall: inter(t.labelSmall),
    );
  }

  static ThemeData get tema {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        error: AppColors.error,
      ),
      textTheme: _textThemeInter(base.textTheme).apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.headline(size: 20),
      ),
      // Inputs: fundo escuro, borda inferior que fica vermelha no foco
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainer,
        hintStyle: AppText.body(color: const Color(0x66E4BEBC)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        enabledBorder: const UnderlineInputBorder(
          borderSide:
              BorderSide(color: AppColors.surfaceContainerHighest, width: 2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.racingRed, width: 2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.racingRed,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: AppText.label(size: 16, color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.performanceBlue,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: AppColors.performanceBlue, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.racingRed,
        inactiveTrackColor: AppColors.surfaceContainerHighest,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.racingRed20,
        valueIndicatorColor: AppColors.racingRed,
        showValueIndicator: ShowValueIndicator.onDrag,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.onSurfaceVariant),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.racingRed
                : AppColors.surfaceContainerHighest),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.racingRed
                : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: AppColors.onSurfaceVariant, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? AppColors.racingRed
                : AppColors.onSurfaceVariant),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: AppText.label(color: AppColors.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceContainer,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle: AppText.label(size: 12),
        unselectedLabelStyle: AppText.label(size: 12),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
