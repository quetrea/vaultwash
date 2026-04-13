import 'package:flutter/material.dart';
import 'package:vaultwash/app/theme/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    return _build(AppColors.light, Brightness.light);
  }

  static ThemeData dark() {
    return _build(AppColors.dark, Brightness.dark);
  }

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: colors.accent,
          brightness: brightness,
        ).copyWith(
          primary: colors.accent,
          onPrimary: brightness == Brightness.dark
              ? colors.background
              : Colors.white,
          secondary: colors.accent,
          onSecondary: brightness == Brightness.dark
              ? colors.background
              : Colors.white,
          surface: colors.surface,
          onSurface: colors.textPrimary,
          error: colors.danger,
          onError: brightness == Brightness.dark
              ? colors.background
              : Colors.white,
          outline: colors.border,
          outlineVariant: colors.borderStrong,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.compact,
      extensions: [colors],
    );

    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.6,
        color: colors.textPrimary,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleSmall: base.textTheme.titleSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(
        fontSize: 14,
        height: 1.45,
        color: colors.textPrimary,
      ),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(
        fontSize: 13,
        height: 1.45,
        color: colors.textPrimary,
      ),
      bodySmall: base.textTheme.bodySmall?.copyWith(
        fontSize: 12,
        height: 1.38,
        color: colors.textSecondary,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow.withValues(alpha: 0.08),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: AppBorders.subtle(colors),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lg,
          side: AppBorders.subtle(colors),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceRaised,
        border: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: AppBorders.subtle(colors),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: AppBorders.subtle(colors),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.sm,
          borderSide: BorderSide(color: colors.accent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: WidgetStateBorderSide.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? BorderSide(color: colors.accent, width: 1.2)
              : AppBorders.strong(colors),
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.surfaceMuted,
        selectedColor: colors.accentSoft,
        side: AppBorders.subtle(colors),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        labelStyle: textTheme.bodySmall,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? BorderSide(color: colors.accent, width: 1.2)
                : AppBorders.subtle(colors),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.accentSoft;
            }

            return colors.surfaceRaised;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colors.textPrimary;
            }

            return colors.textSecondary;
          }),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.sm),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, 38)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.accent,
          foregroundColor: brightness == Brightness.dark
              ? colors.background
              : Colors.white,
          disabledBackgroundColor: colors.surfaceMuted,
          disabledForegroundColor: colors.textMuted,
          minimumSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          side: AppBorders.subtle(colors),
          disabledForegroundColor: colors.textMuted,
          minimumSize: const Size.fromHeight(40),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          disabledForegroundColor: colors.textMuted,
          minimumSize: const Size.fromHeight(36),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(colors.textSecondary),
          overlayColor: WidgetStatePropertyAll(
            colors.accent.withValues(alpha: 0.08),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.sm),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.xs,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: colors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colors.textPrimary,
          borderRadius: AppRadius.sm,
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: colors.surface),
      ),
    );
  }
}
