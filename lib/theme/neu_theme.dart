import 'package:flutter/material.dart';

enum NeuStyle {
  flat,
  convex,
  concave,
  inset,
}

class NeuTheme {
  final bool isDark;

  const NeuTheme({this.isDark = false});

  // Soft Ice-Blue / Powder-Blue Neumorphic Palette (Exact match to reference)
  Color get bg => isDark ? const Color(0xFF161E28) : const Color(0xFFD6E6F5);
  Color get cardBg => isDark ? const Color(0xFF1A2430) : const Color(0xFFDCEAF7);
  Color get surface => isDark ? const Color(0xFF1F2B3A) : const Color(0xFFCDE0F2);
  Color get ringBg => isDark ? const Color(0xFF243244) : const Color(0xFFC8DCF0);

  // Dual Shadows (Diffused, soft, powdery depth)
  Color get lightShadow => isDark
      ? const Color(0xFF253346).withValues(alpha: 0.80)
      : Colors.white.withValues(alpha: 0.95);

  Color get darkShadow => isDark
      ? Colors.black.withValues(alpha: 0.75)
      : const Color(0xFF9CB8D4).withValues(alpha: 0.70);

  Color get lightInnerShadow => isDark
      ? const Color(0xFF253448).withValues(alpha: 0.70)
      : Colors.white.withValues(alpha: 0.90);

  Color get darkInnerShadow => isDark
      ? Colors.black.withValues(alpha: 0.70)
      : const Color(0xFF8FAECB).withValues(alpha: 0.65);

  // Accents
  Color get primary => isDark ? const Color(0xFF64B5F6) : const Color(0xFF2B5C8F);
  Color get primaryLight => isDark ? const Color(0xFF90CAF9) : const Color(0xFF4A7FB8);
  Color get secondary => const Color(0xFFF4A261);
  Color get success => const Color.from(alpha: 1, red: 0.165, green: 0.616, blue: 0.561);
  Color get danger => const Color(0xFFE63946); // Signature red heart accent
  Color get gold => const Color(0xFFF5B041);
  Color get silver => const Color(0xFFA8BDD4);

  // Text Colors
  Color get textPrimary => isDark ? const Color(0xFFF0F5FA) : const Color(0xFF1E3A5F);
  Color get textSecondary => isDark ? const Color(0xFFA0B3C8) : const Color(0xFF5D7A9C);
  Color get textMuted => isDark ? const Color(0xFF6B8098) : const Color(0xFF88A3C2);

  // Subtle Border
  Color get border => isDark
      ? const Color(0xFF253346).withValues(alpha: 0.6)
      : Colors.white.withValues(alpha: 0.7);

  // Generate dual drop shadows with generous soft diffusion
  List<BoxShadow> getShadows({
    double offset = 7.0,
    double blur = 14.0,
    double spread = 0.0,
    bool isPressed = false,
  }) {
    if (isPressed) {
      return [
        BoxShadow(
          color: darkShadow.withValues(alpha: isDark ? 0.40 : 0.30),
          offset: Offset(offset * 0.4, offset * 0.4),
          blurRadius: blur * 0.5,
        ),
      ];
    }

    return [
      BoxShadow(
        color: lightShadow,
        offset: Offset(-offset, -offset),
        blurRadius: blur,
        spreadRadius: spread,
      ),
      BoxShadow(
        color: darkShadow,
        offset: Offset(offset, offset),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];
  }

  // Gradients for soft convex and concave surfaces
  LinearGradient getConvexGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF202C3C), const Color(0xFF141C26)]
          : [const Color(0xFFEAF4FE), const Color(0xFFCCE0F3)],
    );
  }

  LinearGradient getConcaveGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [const Color(0xFF131A24), const Color(0xFF1E2A3A)]
          : [const Color(0xFFC7DBEF), const Color(0xFFEBF5FE)],
    );
  }
}
