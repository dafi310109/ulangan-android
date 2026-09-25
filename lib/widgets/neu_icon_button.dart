import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neu_theme.dart';
import 'neu_box.dart';

class NeuIconButton extends StatefulWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final NeuTheme theme;
  final double size;
  final double iconSize;
  final Color? iconColor;
  final String? tooltip;
  final bool isSelected;
  final bool isEnabled;

  const NeuIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.theme,
    this.size = 46.0,
    this.iconSize = 22.0,
    this.iconColor,
    this.tooltip,
    this.isSelected = false,
    this.isEnabled = true,
  });

  @override
  State<NeuIconButton> createState() => _NeuIconButtonState();
}

class _NeuIconButtonState extends State<NeuIconButton> {
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
    final double scale = _isDown ? 0.92 : 1.0;

    Widget button = AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: NeuBox(
          theme: widget.theme,
          width: widget.size,
          height: widget.size,
          shape: BoxShape.circle,
          style: isPressed ? NeuStyle.inset : NeuStyle.convex,
          depth: isPressed ? 3.0 : 5.0,
          blur: isPressed ? 6.0 : 10.0,
          border: widget.isSelected
              ? Border.all(color: widget.theme.primary.withValues(alpha: 0.6), width: 1.5)
              : null,
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.iconSize,
              color: widget.iconColor ??
                  (widget.isSelected ? widget.theme.primary : widget.theme.textPrimary),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
