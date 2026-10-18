import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, outlined, text }

/// Production-grade custom button with loading state, icons, and responsive content fitting.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 54,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: _buildButtonChild(context),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonChild(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    switch (widget.type) {
      case ButtonType.primary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor ?? scheme.primary,
            foregroundColor: widget.textColor ?? scheme.onPrimary,
            elevation: 0,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: _buildInnerContent(widget.textColor ?? scheme.onPrimary),
        );

      case ButtonType.secondary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.backgroundColor ?? scheme.secondaryContainer,
            foregroundColor: widget.textColor ?? scheme.onSecondaryContainer,
            elevation: 0,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: _buildInnerContent(widget.textColor ?? scheme.onSecondaryContainer),
        );

      case ButtonType.outlined:
        return OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.textColor ?? scheme.primary,
            side: BorderSide(color: widget.backgroundColor ?? scheme.primary, width: 1.5),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: _buildInnerContent(widget.textColor ?? scheme.primary),
        );

      case ButtonType.text:
        return TextButton(
          style: TextButton.styleFrom(
            padding: buttonPadding,
          ),
          onPressed: widget.isLoading ? null : widget.onPressed,
          child: _buildInnerContent(widget.textColor ?? scheme.primary),
        );
    }
  }

  Widget _buildInnerContent(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: color),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.button.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
