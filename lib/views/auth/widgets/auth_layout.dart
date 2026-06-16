import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/helpers/constants.dart';

const double _kFlightPathHeight = 200;
const double _kMountainHeight = 140;

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
    final hScale = (size.height / 800).clamp(0.78, 1.15);

    final horizontalPadding = isWide
        ? 32.0
        : isCompact
            ? 18.0
            : 24.0;

    double v(double base) => base * hScale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _AuthBackdrop(size: size),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    v(16),
                    horizontalPadding,
                    v(32),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - v(48),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: _kContentMaxWidth,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (showBack) ...[
                              SizedBox(height: v(4)),
                              const _AuthBackButton(),
                              SizedBox(height: v(16)),
                            ] else
                              SizedBox(height: v(24)),
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
      color: k_fieldGray,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Get.back(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF191C32),
          ),
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({Key? key, required this.size}) : super(key: key);
  final Size size;

  @override
  Widget build(BuildContext context) {
    final reference = size.shortestSide;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -reference * 0.35,
              right: -reference * 0.3,
              child: _blob(reference * 0.85, 0.18),
            ),
            Positioned(
              bottom: -reference * 0.4,
              left: -reference * 0.25,
              child: _blob(reference * 0.8, 0.10),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: _kFlightPathHeight,
              child: CustomPaint(painter: _FlightPathPainter()),
            ),
            Positioned(
              top: 22,
              right: 14,
              child: Transform.rotate(
                angle: -0.45,
                child: Icon(
                  Icons.flight_rounded,
                  size: 20,
                  color: k_primaryColor.withOpacity(0.7),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: _kMountainHeight,
              child: CustomPaint(painter: _MountainRidgePainter()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double dim, double topOpacity) {
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            k_primaryColor.withOpacity(topOpacity),
            k_primaryColor.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}

class _FlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = k_primaryColor.withOpacity(0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(-size.width * 0.05, size.height * 0.28)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.02,
        size.width * 0.93,
        size.height * 0.18,
      );

    const dash = 6.0;
    const gap = 7.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MountainRidgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Paint()
      ..color = k_primaryColor.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final backPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.55)
      ..lineTo(w * 0.18, h * 0.18)
      ..lineTo(w * 0.32, h * 0.5)
      ..lineTo(w * 0.46, h * 0.12)
      ..lineTo(w * 0.62, h * 0.5)
      ..lineTo(w * 0.76, h * 0.22)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w, h * 0.42)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(backPath, back);

    final front = Paint()
      ..color = k_primaryColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    final frontPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.78)
      ..lineTo(w * 0.14, h * 0.52)
      ..lineTo(w * 0.34, h * 0.72)
      ..lineTo(w * 0.54, h * 0.4)
      ..lineTo(w * 0.7, h * 0.66)
      ..lineTo(w * 0.86, h * 0.46)
      ..lineTo(w, h * 0.6)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(frontPath, front);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthHeroBadge extends StatelessWidget {
  const AuthHeroBadge({Key? key, required this.icon}) : super(key: key);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final dim = isWide ? 76.0 : 64.0;
    return Container(
      width: dim,
      height: dim,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            k_primaryColor,
            k_primaryColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(dim * 0.3),
        boxShadow: [
          BoxShadow(
            color: k_primaryColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: dim * 0.5),
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
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 360;
    final isWide = size.width >= 600;
    final titleSize = isCompact
        ? 28.0
        : isWide
            ? 40.0
            : 34.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontSize: titleSize,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 8),
        CustomText(
          text: subtitle,
          fontSize: isCompact ? 13 : 14,
          color: const Color(0xFF7A869A),
          textAlign: TextAlign.start,
          maxLines: 3,
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomText(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF191C32),
        textAlign: TextAlign.start,
      ),
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
    final isWide = MediaQuery.of(context).size.width >= 600;
    final enabled = !isLoading && onPressed != null;
    return Container(
      width: double.infinity,
      height: isWide ? 60 : 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: k_primaryColor.withOpacity(enabled ? 0.35 : 0.0),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: k_primaryColor,
          disabledBackgroundColor: k_primaryColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: label,
                    fontSize: isWide ? 18 : 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  if (showArrow) ...[
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ],
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
            fontSize: 14,
            color: const Color(0xFF7A869A),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: CustomText(
                text: action,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: k_primaryColor,
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
