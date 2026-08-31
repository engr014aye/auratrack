import 'package:flutter/material.dart';
import '../../core/physics/bounce_physics.dart';
import '../../core/services/sound_service.dart';

class BounceCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double scaleFactor;
  final bool playSound;

  const BounceCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.scaleFactor = AuraSpring.cardScalePressed,
    this.playSound = true,
  });

  @override
  State<BounceCard> createState() => _BounceCardState();
}

class _BounceCardState extends State<BounceCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AuraSpring.pressCurve,
      reverseCurve: AuraSpring.releaseCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
      if (widget.playSound && widget.onTap != null) {
        SoundService().playClick();
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap?.call();
    }
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardBorderRadius = widget.borderRadius ?? BorderRadius.circular(20);
    final effectiveColor = widget.color ?? theme.cardTheme.color;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPress: widget.onLongPress,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Material(
            color: effectiveColor,
            borderRadius: cardBorderRadius,
            clipBehavior: Clip.antiAlias,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: cardBorderRadius,
                border: widget.border ??
                    Border.all(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2D3348)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                boxShadow: widget.boxShadow,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
