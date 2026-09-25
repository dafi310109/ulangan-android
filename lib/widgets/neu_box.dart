import 'package:flutter/material.dart';
import '../theme/neu_theme.dart';

class NeuBox extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final NeuStyle style;
  final NeuTheme theme;
  final Color? customColor;
  final double depth;
  final double blur;
  final double spread;
  final Border? border;

  const NeuBox({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.style = NeuStyle.flat,
    required this.theme,
    this.customColor,
    this.depth = 6.0,
    this.blur = 12.0,
    this.spread = 0.0,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = shape == BoxShape.circle
        ? BorderRadius.circular(999)
        : (borderRadius ?? BorderRadius.circular(16));

    final baseColor = customColor ?? theme.cardBg;

    if (style == NeuStyle.inset) {
      return Container(
        width: width,
        height: height,
        margin: margin,
        child: CustomPaint(
          painter: _NeuInsetPainter(
            radius: effectiveRadius,
            shape: shape,
            depth: depth,
            lightShadowColor: theme.lightInnerShadow,
            darkShadowColor: theme.darkInnerShadow,
            backgroundColor: baseColor,
            border: border,
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      );
    }

    // Flat, convex, concave
    Decoration decoration;
    if (shape == BoxShape.circle) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: (style == NeuStyle.convex || style == NeuStyle.concave)
            ? null
            : baseColor,
        gradient: style == NeuStyle.convex
            ? theme.getConvexGradient()
            : style == NeuStyle.concave
                ? theme.getConcaveGradient()
                : null,
        boxShadow: theme.getShadows(
          offset: depth,
          blur: blur,
          spread: spread,
        ),
        border: border,
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: effectiveRadius,
        color: (style == NeuStyle.convex || style == NeuStyle.concave)
            ? null
            : baseColor,
        gradient: style == NeuStyle.convex
            ? theme.getConvexGradient()
            : style == NeuStyle.concave
                ? theme.getConcaveGradient()
                : null,
        boxShadow: theme.getShadows(
          offset: depth,
          blur: blur,
          spread: spread,
        ),
        border: border,
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );
  }
}

class _NeuInsetPainter extends CustomPainter {
  final BorderRadius radius;
  final BoxShape shape;
  final double depth;
  final Color lightShadowColor;
  final Color darkShadowColor;
  final Color backgroundColor;
  final Border? border;

  _NeuInsetPainter({
    required this.radius,
    required this.shape,
    required this.depth,
    required this.lightShadowColor,
    required this.darkShadowColor,
    required this.backgroundColor,
    this.border,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = shape == BoxShape.circle
        ? RRect.fromRectAndRadius(rect, Radius.circular(size.width / 2))
        : radius.toRRect(rect);

    // 1. Draw base background
    final bgPaint = Paint()..color = backgroundColor;
    if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, size.width / 2, bgPaint);
    } else {
      canvas.drawRRect(rrect, bgPaint);
    }

    // 2. Draw Inset Shadows using clipping
    canvas.save();
    if (shape == BoxShape.circle) {
      canvas.clipPath(Path()..addOval(rect));
    } else {
      canvas.clipRRect(rrect);
    }

    // Dark shadow on top-left (inner)
    final darkShadowPaint = Paint()
      ..color = darkShadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 1.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = depth * 1.5;

    final darkOffset = Offset(depth * 0.5, depth * 0.5);
    final darkRRect = shape == BoxShape.circle
        ? RRect.fromRectAndRadius(rect.shift(-darkOffset), Radius.circular(size.width / 2))
        : radius.toRRect(rect.shift(-darkOffset));
    canvas.drawRRect(darkRRect, darkShadowPaint);

    // Light shadow on bottom-right (inner)
    final lightShadowPaint = Paint()
      ..color = lightShadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, depth * 1.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = depth * 1.5;

    final lightOffset = Offset(depth * 0.5, depth * 0.5);
    final lightRRect = shape == BoxShape.circle
        ? RRect.fromRectAndRadius(rect.shift(lightOffset), Radius.circular(size.width / 2))
        : radius.toRRect(rect.shift(lightOffset));
    canvas.drawRRect(lightRRect, lightShadowPaint);

    canvas.restore();

    // 3. Optional Border
    if (border != null) {
      final borderPaint = Paint()
        ..color = border!.top.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = border!.top.width;

      if (shape == BoxShape.circle) {
        canvas.drawCircle(rect.center, size.width / 2, borderPaint);
      } else {
        canvas.drawRRect(rrect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NeuInsetPainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.lightShadowColor != lightShadowColor ||
        oldDelegate.darkShadowColor != darkShadowColor;
  }
}
