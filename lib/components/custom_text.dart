import 'package:flutter/material.dart';
import 'package:travel_app/helpers/app_colors.dart';

class CustomText extends StatelessWidget {
  const CustomText({
    Key? key,
    required this.text,
    this.fontSize = 14,
    this.letterSpacing = 0,
    this.color,
    this.fontWeight = FontWeight.w500,
    this.textAlign = TextAlign.center,
    this.maxLines,
    this.height,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final double letterSpacing;
  final TextAlign textAlign;
  final int? maxLines;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? AppColors.textDark,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      ),
      textAlign: textAlign,
      maxLines: maxLines ?? 100,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// Convenience semantic constructors used across redesigned screens.

class DisplayText extends StatelessWidget {
  const DisplayText(this.text, {Key? key, this.maxLines = 2, this.color})
      : super(key: key);
  final String text;
  final int maxLines;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.5,
        color: color ?? AppColors.textDark,
        textAlign: TextAlign.start,
        maxLines: maxLines,
      );
}

class HeadlineText extends StatelessWidget {
  const HeadlineText(this.text, {Key? key, this.color}) : super(key: key);
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: color ?? AppColors.textDark,
        textAlign: TextAlign.start,
      );
}

class TitleText extends StatelessWidget {
  const TitleText(this.text,
      {Key? key, this.color, this.maxLines, this.textAlign})
      : super(key: key);
  final String text;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textDark,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
      );
}

class BodyText extends StatelessWidget {
  const BodyText(this.text,
      {Key? key, this.color, this.maxLines, this.textAlign})
      : super(key: key);
  final String text;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: color ?? AppColors.textBody,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
      );
}

class MutedText extends StatelessWidget {
  const MutedText(this.text,
      {Key? key, this.fontSize = 12, this.textAlign, this.maxLines})
      : super(key: key);
  final String text;
  final double fontSize;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text,
        fontSize: fontSize,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
      );
}

class OverlineText extends StatelessWidget {
  const OverlineText(this.text, {Key? key, this.color}) : super(key: key);
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomText(
        text: text.toUpperCase(),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: color ?? AppColors.textMuted,
        textAlign: TextAlign.start,
      );
}
