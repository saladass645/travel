import 'package:flutter/material.dart';

// ============================================================ palette
//
// "Voyage" — deep teal anchor with a warm coral accent. Designed to evoke
// ocean depth (primary) and golden-hour skies (accent), with a soft warm
// off-white background that feels paper-like, not sterile.

const Color k_primary = Color(0xFF0F766E);          // deep teal
const Color k_primaryDark = Color(0xFF0B5C56);      // pressed / shadows
const Color k_primarySoft = Color(0xFFE6F1EF);      // tint surfaces
const Color k_accent = Color(0xFFFF7B5A);           // coral CTA / highlight
const Color k_accentSoft = Color(0xFFFFE5DE);
const Color k_amber = Color(0xFFFFB347);            // ratings, badges

const Color k_bg = Color(0xFFFAFAF7);               // warm off-white app bg
const Color k_surface = Color(0xFFFFFFFF);
const Color k_field = Color(0xFFF1F3EE);            // cool field background
const Color k_field2 = Color(0xFFEDEFE9);           // slightly darker field
const Color k_border = Color(0xFFE5E8E0);

const Color k_textDark = Color(0xFF0E1A2E);
const Color k_textBody = Color(0xFF2A3142);
const Color k_textMuted = Color(0xFF6B7589);
const Color k_textFaint = Color(0xFF98A1B3);

const Color k_success = Color(0xFF4FB286);
const Color k_warning = Color(0xFFF4A261);
const Color k_error = Color(0xFFE76F51);

// Backwards-compatible aliases used across older screens.
const Color k_canvas = k_bg;
const Color k_buttonGray = Color(0xFFA9A9A9);
const Color k_fieldGray = k_field;
const Color k_fontGray = k_textMuted;

// ============================================================ radii / spacing

const double k_radSm = 12;
const double k_radMd = 18;
const double k_radLg = 24;
const double k_radXl = 32;

const double k_pad = 22; // canonical screen horizontal padding

// ============================================================ shadows

const List<BoxShadow> k_shadowSoft = [
  BoxShadow(
    color: Color(0x14000000),
    blurRadius: 18,
    offset: Offset(0, 8),
  ),
];

const List<BoxShadow> k_shadowCard = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 14,
    offset: Offset(0, 6),
  ),
];

const List<BoxShadow> k_shadowPress = [
  BoxShadow(
    color: Color(0x33000000),
    blurRadius: 24,
    offset: Offset(0, 14),
  ),
];

// ============================================================ gradients

const LinearGradient k_gradPrimary = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F766E), Color(0xFF115E59)],
);

const LinearGradient k_gradAccent = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF8C73), Color(0xFFFF7B5A)],
);

const LinearGradient k_gradHero = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F766E), Color(0xFF1A535C), Color(0xFFFF7B5A)],
  stops: [0.0, 0.55, 1.0],
);

// ============================================================ storage keys

const String k_langKey = "lang";
const String k_userKey = "user";
const String k_onBoardingKey = "onBoarding";

// ============================================================ legacy MaterialColor

const int _kPrimaryValue = 0xFF0F766E;
const MaterialColor k_primaryColor = MaterialColor(
  _kPrimaryValue,
  <int, Color>{
    50:  Color(0xFFE7F1F0),
    100: Color(0xFFC1DDDA),
    200: Color(0xFF98C8C2),
    300: Color(0xFF6FB2AA),
    400: Color(0xFF4FA29A),
    500: Color(_kPrimaryValue),
    600: Color(0xFF0D6B63),
    700: Color(0xFF0B5C56),
    800: Color(0xFF094E49),
    900: Color(0xFF053633),
  },
);
