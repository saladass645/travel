import 'package:flutter/material.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : super(key: key);

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: title,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.3,
                textAlign: TextAlign.start,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                CustomText(
                  text: subtitle!,
                  fontSize: 12,
                  color: AppColors.textMuted,
                  textAlign: TextAlign.start,
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                CustomText(
                  text: actionLabel!,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: k_primary,
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_rounded,
                    size: 16, color: k_primary),
              ],
            ),
          ),
      ],
    );
  }
}
