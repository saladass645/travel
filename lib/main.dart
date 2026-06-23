import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Binding;
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/binding.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/multi_language/langeuages/translations.dart';
import 'package:travel_app/views/splash/splash_screen.dart';

const String _kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const String _kSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (_kSupabaseUrl.isEmpty || _kSupabaseAnonKey.isEmpty) {
    throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define.');
  }
  await Supabase.initialize(
    url: _kSupabaseUrl,
    anonKey: _kSupabaseAnonKey,
  );
  await GetStorage.init();
  // Hydrate dark mode BEFORE the first build so the splash already paints
  // in the saved mode (avoids a flash of light theme on dark-mode launches).
  AppColors.isDark = CatchStorage.get('isDarkMode') == true;
  MainUser.instance.onInit();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  String _getLanguage() {
    String lang = CatchStorage.get(k_langKey) ?? "en";
    return lang;
  }

  String? _getFont() {
    if (_getLanguage() == "en") {
      return GoogleFonts.poppins().fontFamily;
    }
    if (_getLanguage() == "ar") {
      return GoogleFonts.tajawal().fontFamily;
    }
    return GoogleFonts.poppins().fontFamily;
  }

  ThemeData _buildTheme({required bool dark}) {
    final bg = dark ? const Color(0xFF0E1414) : const Color(0xFFFAFAF7);
    final surface = dark ? const Color(0xFF1A1F1F) : Colors.white;
    final field = dark ? const Color(0xFF252B2B) : const Color(0xFFF1F3EE);
    final textDark =
        dark ? const Color(0xFFF2F2EE) : const Color(0xFF0E1A2E);

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      primarySwatch: k_primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: k_primary,
        primary: k_primary,
        secondary: k_accent,
        surface: surface,
        background: bg,
        brightness: dark ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        contentTextStyle: TextStyle(
            color: dark ? const Color(0xFF0E1414) : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(k_radSm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(k_radSm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(k_radSm),
          borderSide: const BorderSide(color: k_primary, width: 1.5),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(k_radLg)),
      ),
      fontFamily: _getFont(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Voyage',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(dark: false),
      darkTheme: _buildTheme(dark: true),
      themeMode:
          AppColors.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(_getLanguage()),
      fallbackLocale: const Locale("en"),
      translations: Translation(),
      initialBinding: Binding(),
      home: const SplashScreen(),
    );
  }
}
