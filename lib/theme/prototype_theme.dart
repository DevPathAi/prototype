import 'package:flutter/material.dart';

@immutable
class PrototypeTokens extends ThemeExtension<PrototypeTokens> {
  const PrototypeTokens({
    required this.surfaceMuted,
    required this.border,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color surfaceMuted;
  final Color border;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  @override
  PrototypeTokens copyWith({
    Color? surfaceMuted,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? info,
  }) {
    return PrototypeTokens(
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      info: info ?? this.info,
    );
  }

  @override
  PrototypeTokens lerp(ThemeExtension<PrototypeTokens>? other, double t) {
    if (other is! PrototypeTokens) {
      return this;
    }
    return PrototypeTokens(
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

ThemeData buildPrototypeTheme() {
  const seed = Color(0xFF1F6F68);
  const tokens = PrototypeTokens(
    surfaceMuted: Color(0xFFE8EEE8),
    border: Color(0xFFD9DED8),
    success: Color(0xFF1F6F68),
    warning: Color(0xFFB7791F),
    danger: Color(0xFF9D3A3A),
    info: Color(0xFF2D6CDF),
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: const Color(0xFFF7F8F3),
    fontFamily: 'Roboto',
    extensions: const [tokens],
    chipTheme: ChipThemeData(
      side: const BorderSide(color: Color(0xFFD9DED8)),
      selectedColor: seed.withValues(alpha: 0.12),
    ),
    focusColor: seed.withValues(alpha: 0.18),
  );
}

PrototypeTokens prototypeTokens(BuildContext context) {
  return Theme.of(context).extension<PrototypeTokens>()!;
}
