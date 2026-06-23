import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:travel_app/components/custom_text.dart';

class GlassChip extends StatelessWidget {
  const GlassChip({
    Key? key,
    required this.label,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.foreground = Colors.white,
    this.tint = const Color(0x33FFFFFF),
  }) : super(key: key);

  final String label;
  final IconData? icon;
  final EdgeInsets padding;
  final Color foreground;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
                color: Colors.white.withOpacity(0.25), width: 0.6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: foreground, size: 13),
                const SizedBox(width: 4),
              ],
              CustomText(
                text: label,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: foreground,
                letterSpacing: 0.3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    Key? key,
    required this.icon,
    required this.onTap,
    this.size = 42,
    this.color = Colors.white,
    this.background = const Color(0x33FFFFFF),
    this.glass = true,
  }) : super(key: key);

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final Color background;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final inner = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.white.withOpacity(glass ? 0.25 : 0), width: 0.6),
      ),
      child: Icon(icon, color: color, size: size * 0.45),
    );

    final wrapped = glass
        ? ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: inner,
            ),
          )
        : inner;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: wrapped,
      ),
    );
  }
}
