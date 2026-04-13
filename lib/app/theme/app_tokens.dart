import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.sidebarSurface,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.surfaceSunken,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.shadow,
  });

  static const light = AppColors(
    background: Color(0xFFF4F5F1),
    sidebarSurface: Color(0xFFF8F8F4),
    surface: Color(0xFFFCFCF9),
    surfaceMuted: Color(0xFFF1F2ED),
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFEEF0E8),
    border: Color(0xFFD9DBD1),
    borderStrong: Color(0xFFC7CAC0),
    textPrimary: Color(0xFF171918),
    textSecondary: Color(0xFF545C58),
    textMuted: Color(0xFF757D78),
    accent: Color(0xFF205848),
    accentSoft: Color(0xFFE4F0EA),
    success: Color(0xFF2E6F53),
    successSoft: Color(0xFFE6F1EB),
    warning: Color(0xFF886022),
    warningSoft: Color(0xFFF7EDD8),
    danger: Color(0xFF8A3E3E),
    dangerSoft: Color(0xFFF6E8E7),
    shadow: Color(0xFF101311),
  );

  static const dark = AppColors(
    background: Color(0xFF0F1110),
    sidebarSurface: Color(0xFF131614),
    surface: Color(0xFF171A18),
    surfaceMuted: Color(0xFF1C201E),
    surfaceRaised: Color(0xFF202422),
    surfaceSunken: Color(0xFF121513),
    border: Color(0xFF2C312E),
    borderStrong: Color(0xFF3A403D),
    textPrimary: Color(0xFFF3F5F2),
    textSecondary: Color(0xFFC4CBC5),
    textMuted: Color(0xFF9AA29D),
    accent: Color(0xFF7FB7A0),
    accentSoft: Color(0xFF20352C),
    success: Color(0xFF7AC49C),
    successSoft: Color(0xFF173225),
    warning: Color(0xFFE0B36B),
    warningSoft: Color(0xFF332711),
    danger: Color(0xFFE29C9C),
    dangerSoft: Color(0xFF381E1E),
    shadow: Color(0xFF000000),
  );

  final Color background;
  final Color sidebarSurface;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceRaised;
  final Color surfaceSunken;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color shadow;

  @override
  AppColors copyWith({
    Color? background,
    Color? sidebarSurface,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceRaised,
    Color? surfaceSunken,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? success,
    Color? successSoft,
    Color? warning,
    Color? warningSoft,
    Color? danger,
    Color? dangerSoft,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      sidebarSurface: sidebarSurface ?? this.sidebarSurface,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }

    return AppColors(
      background: Color.lerp(background, other.background, t) ?? background,
      sidebarSurface:
          Color.lerp(sidebarSurface, other.sidebarSurface, t) ?? sidebarSurface,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceMuted:
          Color.lerp(surfaceMuted, other.surfaceMuted, t) ?? surfaceMuted,
      surfaceRaised:
          Color.lerp(surfaceRaised, other.surfaceRaised, t) ?? surfaceRaised,
      surfaceSunken:
          Color.lerp(surfaceSunken, other.surfaceSunken, t) ?? surfaceSunken,
      border: Color.lerp(border, other.border, t) ?? border,
      borderStrong:
          Color.lerp(borderStrong, other.borderStrong, t) ?? borderStrong,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      success: Color.lerp(success, other.success, t) ?? success,
      successSoft: Color.lerp(successSoft, other.successSoft, t) ?? successSoft,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t) ?? warningSoft,
      danger: Color.lerp(danger, other.danger, t) ?? danger,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t) ?? dangerSoft,
      shadow: Color.lerp(shadow, other.shadow, t) ?? shadow,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
}

abstract final class AppRadius {
  static final sm = BorderRadius.circular(10);
  static final md = BorderRadius.circular(14);
  static final lg = BorderRadius.circular(18);
  static final xl = BorderRadius.circular(24);
}

abstract final class AppBorders {
  static BorderSide subtle(AppColors colors) =>
      BorderSide(color: colors.border, width: 1);

  static BorderSide strong(AppColors colors) =>
      BorderSide(color: colors.borderStrong, width: 1);
}

abstract final class AppShadows {
  static List<BoxShadow> surface(AppColors colors) {
    final darkSurface = colors.background.computeLuminance() < 0.2;
    return [
      BoxShadow(
        color: colors.shadow.withValues(alpha: darkSurface ? 0.24 : 0.06),
        offset: const Offset(0, 10),
        blurRadius: 28,
        spreadRadius: -20,
      ),
    ];
  }
}

abstract final class AppDurations {
  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 200);
}
