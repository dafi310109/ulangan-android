import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';

enum CoinMaterial {
  gold,
  silver,
  bronze,
}

class CoinWidget extends StatelessWidget {
  final bool showKepala;
  final double size;
  final double flipProgress; // 0.0 to 1.0 (or continuous)
  final double rotationAngle; // radians
  final CoinMaterial material;
  final NeuTheme theme;
  final VoidCallback? onTap;

  const CoinWidget({
    super.key,
    required this.showKepala,
    this.size = 200.0,
    this.flipProgress = 0.0,
    this.rotationAngle = 0.0,
    this.material = CoinMaterial.gold,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Normalise angle to 0..2*pi
    final double normAngle = rotationAngle % (2 * math.pi);
    // Face visibility: from 0 to pi/2 and 3pi/2 to 2pi -> front face,
    // from pi/2 to 3pi/2 -> back face (mirrored)
    final bool isFront = normAngle <= (math.pi / 2) || normAngle >= (3 * math.pi / 2);
    final bool displayKepala = isFront ? showKepala : !showKepala;

    // Calculate vertical jump height during flip (peaks at progress = 0.5)
    final double jumpOffset = -math.sin(flipProgress * math.pi) * 85.0;
    // Scale slightly as it approaches camera
    final double scale = 1.0 + (math.sin(flipProgress * math.pi) * 0.15);

    // Ground shadow properties
    final double shadowScale = 1.0 + (math.sin(flipProgress * math.pi) * 0.35);
    final double shadowOpacity = (0.45 - (math.sin(flipProgress * math.pi) * 0.25)).clamp(0.1, 0.45);
    final double shadowBlur = 10.0 + (math.sin(flipProgress * math.pi) * 20.0);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size + 24,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. Dynamic Ground Shadow
            Positioned(
              bottom: 4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                width: (size * 0.75) * shadowScale,
                height: (size * 0.22) * shadowScale,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: (theme.isDark ? Colors.black : const Color(0xFF6B7280))
                          .withValues(alpha: shadowOpacity),
                      blurRadius: shadowBlur,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 3D Flipping Coin
            Transform.translate(
              offset: Offset(0, jumpOffset),
              child: Transform.scale(
                scale: scale,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018) // 3D Perspective
                    ..rotateX(rotationAngle),
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: theme.getShadows(
                        offset: 7,
                        blur: 15,
                        spread: 1,
                      ),
                    ),
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: _CoinFacePainter(
                        isKepala: displayKepala,
                        material: material,
                        rotationAngle: rotationAngle,
                        isDark: theme.isDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoinFacePainter extends CustomPainter {
  final bool isKepala;
  final CoinMaterial material;
  final double rotationAngle;
  final bool isDark;

  _CoinFacePainter({
    required this.isKepala,
    required this.material,
    required this.rotationAngle,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Palette setup based on material
    late final List<Color> rimColors;
    late final List<Color> faceColors;
    late final Color textColor;
    late final Color highlightColor;
    late final Color shadowColor;
    late final Color accentColor;

    switch (material) {
      case CoinMaterial.gold:
        rimColors = [
          const Color(0xFFFFF1B8),
          const Color(0xFFF5B041),
          const Color(0xFFD48B1A),
          const Color(0xFF8B570A),
          const Color(0xFFF9D268),
        ];
        faceColors = [
          const Color(0xFFFDEAA8),
          const Color(0xFFF39C12),
          const Color(0xFFD68910),
        ];
        textColor = const Color(0xFF6E4304);
        highlightColor = const Color(0xFFFFF9E6).withValues(alpha: 0.85);
        shadowColor = const Color(0xFF533100).withValues(alpha: 0.65);
        accentColor = const Color(0xFFF7DC6F);
        break;

      case CoinMaterial.silver:
        rimColors = [
          const Color(0xFFFFFFFF),
          const Color(0xFFCFD8DC),
          const Color(0xFF90A4AE),
          const Color(0xFF607D8B),
          const Color(0xFFECEFF1),
        ];
        faceColors = [
          const Color(0xFFFFFFFF),
          const Color(0xFFECEFF1),
          const Color(0xFFB0BEC5),
        ];
        textColor = const Color(0xFF37474F);
        highlightColor = Colors.white.withValues(alpha: 0.9);
        shadowColor = const Color(0xFF263238).withValues(alpha: 0.6);
        accentColor = const Color(0xFFE0E0E0);
        break;

      case CoinMaterial.bronze:
        rimColors = [
          const Color(0xFFFFDAB9),
          const Color(0xFFCD7F32),
          const Color(0xFF8B4513),
          const Color(0xFF5A2A0C),
          const Color(0xFFE89758),
        ];
        faceColors = [
          const Color(0xFFF0AF86),
          const Color(0xFFCD7F32),
          const Color(0xFFA0522D),
        ];
        textColor = const Color(0xFF3E1A08);
        highlightColor = const Color(0xFFFFE4CE).withValues(alpha: 0.8);
        shadowColor = const Color(0xFF3B1806).withValues(alpha: 0.7);
        accentColor = const Color(0xFFD38B5D);
        break;
    }

    // 1. Outer Metallic Rim Gradient
    final rimPaint = Paint()
      ..shader = SweepGradient(
        colors: rimColors,
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        transform: GradientRotation(rotationAngle * 0.5),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, rimPaint);

    // 2. Beaded Rim / Milled edge dots
    final beadPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;
    final beadShadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;

    const int beadCount = 36;
    final double beadRadius = radius * 0.91;
    for (int i = 0; i < beadCount; i++) {
      final double angle = (i * 2 * math.pi / beadCount);
      final double bx = center.dx + beadRadius * math.cos(angle);
      final double by = center.dy + beadRadius * math.sin(angle);

      // shadow bead
      canvas.drawCircle(Offset(bx + 0.6, by + 0.6), 1.6, beadShadowPaint);
      // highlight bead
      canvas.drawCircle(Offset(bx - 0.4, by - 0.4), 1.6, beadPaint);
    }

    // 3. Inner Groove Ring
    final groovePaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius * 0.83, groovePaint);

    final innerHighlightRing = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.81, innerHighlightRing);

    // 4. Central Sunken Field (Face)
    final facePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.3),
        radius: 0.9,
        colors: faceColors,
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.80));
    canvas.drawCircle(center, radius * 0.80, facePaint);

    // 5. Draw Emblem / Face Content
    if (isKepala) {
      _drawKepalaFace(
        canvas,
        center,
        radius * 0.80,
        textColor,
        highlightColor,
        shadowColor,
        accentColor,
      );
    } else {
      _drawEkorFace(
        canvas,
        center,
        radius * 0.80,
        textColor,
        highlightColor,
        shadowColor,
        accentColor,
      );
    }

    // 6. Dynamic Shimmer / Light Sheen across surface
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -1.0),
        end: const Alignment(1.0, 1.0),
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.2, 0.5, 0.8],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.80, sheenPaint);
  }

  void _drawKepalaFace(
    Canvas canvas,
    Offset center,
    double innerRadius,
    Color textColor,
    Color highlightColor,
    Color shadowColor,
    Color accentColor,
  ) {
    // Top text: REPUBLIK INDONESIA
    _drawCurvedText(
      canvas,
      center,
      innerRadius * 0.72,
      'REPUBLIK INDONESIA',
      math.pi * 1.5,
      textColor,
      shadowColor,
      highlightColor,
      fontSize: innerRadius * 0.12,
      isTop: true,
    );

    // Garuda / National Eagle Motif in Center
    _drawGarudaEmblem(canvas, center, innerRadius * 0.42, textColor, highlightColor, shadowColor);

    // Bottom Badge text: KEPALA
    _drawCurvedText(
      canvas,
      center,
      innerRadius * 0.72,
      '★ KEPALA ★',
      math.pi * 0.5,
      textColor,
      shadowColor,
      highlightColor,
      fontSize: innerRadius * 0.14,
      isTop: false,
    );
  }

  void _drawGarudaEmblem(
    Canvas canvas,
    Offset center,
    double scale,
    Color textColor,
    Color highlightColor,
    Color shadowColor,
  ) {
    // Draw stylized Garuda silhouette with wings and crest
    final path = Path();
    // Head / Crown
    path.moveTo(center.dx, center.dy - scale * 0.85);
    path.lineTo(center.dx + scale * 0.15, center.dy - scale * 0.65);
    path.lineTo(center.dx + scale * 0.08, center.dy - scale * 0.50);

    // Right Wing Feathers
    path.lineTo(center.dx + scale * 0.85, center.dy - scale * 0.45);
    path.lineTo(center.dx + scale * 0.95, center.dy - scale * 0.20);
    path.lineTo(center.dx + scale * 0.75, center.dy - scale * 0.05);
    path.lineTo(center.dx + scale * 0.85, center.dy + scale * 0.10);
    path.lineTo(center.dx + scale * 0.55, center.dy + scale * 0.25);

    // Body / Shield bottom right
    path.lineTo(center.dx + scale * 0.25, center.dy + scale * 0.50);
    path.lineTo(center.dx, center.dy + scale * 0.80); // Tail tip

    // Left Wing Feathers (symmetrical)
    path.lineTo(center.dx - scale * 0.25, center.dy + scale * 0.50);
    path.lineTo(center.dx - scale * 0.55, center.dy + scale * 0.25);
    path.lineTo(center.dx - scale * 0.85, center.dy + scale * 0.10);
    path.lineTo(center.dx - scale * 0.75, center.dy - scale * 0.05);
    path.lineTo(center.dx - scale * 0.95, center.dy - scale * 0.20);
    path.lineTo(center.dx - scale * 0.85, center.dy - scale * 0.45);

    path.lineTo(center.dx - scale * 0.08, center.dy - scale * 0.50);
    path.lineTo(center.dx - scale * 0.15, center.dy - scale * 0.65);
    path.close();

    // Embossed shadow
    canvas.save();
    canvas.translate(1.0, 1.2);
    final sPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, sPaint);
    canvas.restore();

    // Embossed highlight
    canvas.save();
    canvas.translate(-0.8, -0.8);
    final hPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, hPaint);
    canvas.restore();

    // Main Emblem Body
    final mainPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, mainPaint);

    // Central Shield
    final shieldPath = Path();
    shieldPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: scale * 0.50, height: scale * 0.60),
      const Radius.circular(5),
    ));
    final shieldPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldPaint);

    final shieldBorderPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(shieldPath, shieldBorderPaint);

    // Central Star on shield
    _drawStar(canvas, center, scale * 0.14, textColor);
  }

  void _drawEkorFace(
    Canvas canvas,
    Offset center,
    double innerRadius,
    Color textColor,
    Color highlightColor,
    Color shadowColor,
    Color accentColor,
  ) {
    // Top text: BANK INDONESIA
    _drawCurvedText(
      canvas,
      center,
      innerRadius * 0.72,
      'BANK INDONESIA',
      math.pi * 1.5,
      textColor,
      shadowColor,
      highlightColor,
      fontSize: innerRadius * 0.12,
      isTop: true,
    );

    // Central Bold Value: 1000
    final valueText = '1000';
    final textPainter = TextPainter(
      text: TextSpan(
        text: valueText,
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.w900,
          fontSize: innerRadius * 0.44,
          letterSpacing: -1.0,
          foreground: Paint()
            ..color = textColor,
          shadows: [
            Shadow(
              offset: const Offset(1.5, 1.5),
              color: shadowColor,
              blurRadius: 1.0,
            ),
            Shadow(
              offset: const Offset(-1.0, -1.0),
              color: highlightColor,
              blurRadius: 1.0,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height * 0.68)),
    );

    // Subtext: RUPIAH
    final rupiahPainter = TextPainter(
      text: TextSpan(
        text: 'RUPIAH',
        style: TextStyle(
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.w800,
          fontSize: innerRadius * 0.14,
          letterSpacing: 2.5,
          color: textColor,
          shadows: [
            Shadow(
              offset: const Offset(1.0, 1.0),
              color: shadowColor,
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rupiahPainter.layout();
    rupiahPainter.paint(
      canvas,
      Offset(center.dx - (rupiahPainter.width / 2), center.dy + (textPainter.height * 0.15)),
    );

    // Bottom Badge text: EKOR
    _drawCurvedText(
      canvas,
      center,
      innerRadius * 0.72,
      '★ EKOR ★',
      math.pi * 0.5,
      textColor,
      shadowColor,
      highlightColor,
      fontSize: innerRadius * 0.14,
      isTop: false,
    );

    // Laurel / Floral Branch Wreath on sides
    _drawLaurelWreath(canvas, center, innerRadius * 0.65, textColor, highlightColor);
  }

  void _drawLaurelWreath(
    Canvas canvas,
    Offset center,
    double wreathRadius,
    Color color,
    Color highlight,
  ) {
    final leafPaint = Paint()
      ..color = color.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Left and right arc leaves
    for (int side = -1; side <= 1; side += 2) {
      for (int i = 0; i < 5; i++) {
        final double angle = (math.pi / 2) + (side * (0.45 + i * 0.22));
        final lx = center.dx + wreathRadius * math.cos(angle);
        final ly = center.dy + wreathRadius * math.sin(angle);

        canvas.save();
        canvas.translate(lx, ly);
        canvas.rotate(angle + (side > 0 ? 0.3 : -0.3));
        canvas.drawOval(
          Rect.fromCenter(center: Offset.zero, width: 9, height: 4),
          leafPaint,
        );
        canvas.restore();
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final double outerAngle = -math.pi / 2 + (i * 2 * math.pi / 5);
      final double innerAngle = outerAngle + math.pi / 5;
      final double ox = center.dx + size * math.cos(outerAngle);
      final double oy = center.dy + size * math.sin(outerAngle);
      final double ix = center.dx + (size * 0.45) * math.cos(innerAngle);
      final double iy = center.dy + (size * 0.45) * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();

    final starPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, starPaint);
  }

  void _drawCurvedText(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double centralAngle,
    Color textColor,
    Color shadowColor,
    Color highlightColor, {
    required double fontSize,
    required bool isTop,
  }) {
    final double letterSpacing = 0.12;
    final int len = text.length;
    final double totalArc = (len - 1) * letterSpacing;
    final double startAngle = isTop
        ? centralAngle - (totalArc / 2)
        : centralAngle + (totalArc / 2);

    for (int i = 0; i < len; i++) {
      final char = text[i];
      final double angle = isTop
          ? startAngle + (i * letterSpacing)
          : startAngle - (i * letterSpacing);

      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      final tp = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            fontFamily: 'sans-serif',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: textColor,
            shadows: [
              Shadow(offset: const Offset(1, 1), color: shadowColor, blurRadius: 0.5),
              Shadow(offset: const Offset(-0.8, -0.8), color: highlightColor, blurRadius: 0.5),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(isTop ? angle + (math.pi / 2) : angle - (math.pi / 2));
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CoinFacePainter oldDelegate) {
    return oldDelegate.isKepala != isKepala ||
        oldDelegate.material != material ||
        oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.isDark != isDark;
  }
}
