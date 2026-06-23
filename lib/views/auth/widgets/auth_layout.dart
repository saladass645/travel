import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/constants.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    Key? key,
    required this.children,
    this.showBack = false,
  }) : super(key: key);

  final List<Widget> children;
  final bool showBack;

  static const double _kContentMaxWidth = 460;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 360;
    final isWide = size.width >= 600;

    final horizontalPadding = isWide
        ? 36.0
        : isCompact
            ? 20.0
            : k_pad;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                      horizontalPadding, 16, horizontalPadding, 32),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxWidth: _kContentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showBack) ...[
                              const SizedBox(height: 4),
                              const _AuthBackButton(),
                              const SizedBox(height: 20),
                            ] else
                              const SizedBox(height: 24),
                            ...children,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.back(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: k_shadowCard,
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textDark),
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      k_primary.withOpacity(0.16),
                      k_primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 360,
                height: 360,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      k_accent.withOpacity(0.14),
                      k_accent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthHeroBadge extends StatelessWidget {
  const AuthHeroBadge({Key? key, required this.icon}) : super(key: key);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: k_gradPrimary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: k_primary.withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 36),
    );
  }
}

class AuthTitle extends StatelessWidget {
  const AuthTitle({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DisplayText(title, maxLines: 2),
        const SizedBox(height: 8),
        BodyText(subtitle, maxLines: 3),
      ],
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {Key? key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: OverlineText(text.toUpperCase()),
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.showArrow = true,
  }) : super(key: key);

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: k_primary.withOpacity(onPressed == null ? 0 : 0.32),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: isLoading ? null : onPressed,
          child: Ink(
            decoration: BoxDecoration(
              gradient: k_gradPrimary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomText(
                          text: label,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        if (showArrow) ...[
                          const SizedBox(width: 8),
                          const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthFooterSwitch extends StatelessWidget {
  const AuthFooterSwitch({
    Key? key,
    required this.leading,
    required this.action,
    required this.onTap,
  }) : super(key: key);

  final String leading;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          CustomText(
            text: leading,
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: CustomText(
                text: action,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: k_primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

double authVScale(BuildContext context) {
  final h = MediaQuery.of(context).size.height;
  return (h / 800).clamp(0.78, 1.15);
}
