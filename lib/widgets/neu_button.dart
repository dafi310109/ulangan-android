import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neu_theme.dart';
import 'neu_box.dart';

class NeuButton extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;
  final NeuTheme theme;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final bool isSelected;
  final bool isEnabled;

  const NeuButton({
    super.key,
    required this.onTap,
    required this.child,
    required this.theme,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.color,
    this.isSelected = false,
    this.isEnabled = true,
  });

  @override
  State<NeuButton> createState() => _NeuButtonState();
}

class _NeuButtonState extends State<NeuButton> with SingleTickerProviderStateMixin {
  bool _isDown = false;

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isDown = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isEnabled) return;
    setState(() => _isDown = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (!widget.isEnabled) return;
    setState(() => _isDown = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isPressed = _isDown || widget.isSelected;
    final double scale = _isDown ? 0.96 : 1.0;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedOpacity(
          opacity: widget.isEnabled ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: NeuBox(
            theme: widget.theme,
            width: widget.width,
            height: widget.height,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            style: isPressed ? NeuStyle.inset : NeuStyle.convex,
            customColor: widget.color ?? (widget.isSelected ? widget.theme.surface : null),
            depth: isPressed ? 4.0 : 7.0,
            blur: isPressed ? 8.0 : 14.0,
            border: widget.isSelected
                ? Border.all(color: widget.theme.primary.withValues(alpha: 0.5), width: 1.5)
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
