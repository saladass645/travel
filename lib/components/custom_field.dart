import 'package:flutter/material.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class CustomField extends StatelessWidget {
  const CustomField({
    Key? key,
    required this.hint,
    this.suffixIcon,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.radius = k_radSm,
    this.fillColor,
    this.textDirection,
    this.enabled,
    this.onTap,
    this.prefixIcon,
    this.onChanged,
    this.keyboardType,
    this.initialValue,
    required String hintText,
    required bool readOnly,
  }) : super(key: key);
  final String hint;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final double radius;
  final Color? fillColor;
  final TextDirection? textDirection;
  final bool? enabled;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onTap: onTap,
      enabled: enabled,
      obscureText: obscureText,
      controller: controller,
      validator: validator,
      textDirection: textDirection,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        hintTextDirection: textDirection,
        filled: true,
        fillColor: fillColor ?? AppColors.field,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: k_primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: k_error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: k_error, width: 1.5),
        ),
      ),
    );
  }
}
