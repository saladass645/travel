import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide Binding;
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

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        canvasColor: k_canvas,
        primarySwatch: k_primaryColor,
        fontFamily: _getFont(),
      ),
      locale: Locale(_getLanguage()),
      fallbackLocale: Locale("en"),
      translations: Translation(),
      initialBinding: Binding(),
      home: SplashScreen(),
    );
  }
}
