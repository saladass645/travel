import 'package:flutter/material.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

enum CustomButtonVariant { filled, outline, ghost }

class CustomButton extends StatelessWidget {
  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.radius = k_radMd,
    this.height = 56,
    this.variant = CustomButtonVariant.filled,
    this.icon,
    this.loading = false,
    this.gradient,
  }) : super(key: key);

  final String text;
  final Color? color;
  final Color? textColor;
  final void Function()? onPressed;
  final double? width;
  final double radius;
  final double height;
  final CustomButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final Gradient? gradient;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final fillColor = color ?? k_primary;
    final fg = textColor ??
        (variant == CustomButtonVariant.filled ? Colors.white : fillColor);

    final radiusObj = BorderRadius.circular(radius);

    final core = SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radiusObj,
          onTap: _enabled ? onPressed : null,
          child: Ink(
            decoration: BoxDecoration(
              gradient: variant == CustomButtonVariant.filled
                  ? (gradient ?? k_gradPrimary)
                  : null,
              color: variant == CustomButtonVariant.filled
                  ? null
                  : (variant == CustomButtonVariant.outline
                      ? Colors.transparent
                      : AppColors.primarySoft),
              borderRadius: radiusObj,
              border: variant == CustomButtonVariant.outline
                  ? Border.all(color: fillColor, width: 1.5)
                  : null,
            ),
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(fg),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: fg, size: 18),
                          const SizedBox(width: 8),
                        ],
                        CustomText(
                          text: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          letterSpacing: 0.2,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );

    if (variant != CustomButtonVariant.filled || !_enabled) return core;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radiusObj,
        boxShadow: [
          BoxShadow(
            color: fillColor.withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: core,
    );
  }
}
