import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/helpers/app_colors.dart';
import 'package:travel_app/helpers/catch_storage.dart';

class ThemeController extends GetxController {
  static const _key = 'isDarkMode';

  bool get isDark => AppColors.isDark;

  @override
  void onInit() {
    super.onInit();
    final saved = CatchStorage.get(_key);
    AppColors.isDark = saved == true;
    _applySystemMode();
  }

  void toggle() => setDark(!isDark);

  Future<void> setDark(bool value) async {
    AppColors.isDark = value;
    await CatchStorage.save(_key, value);
    _applySystemMode();
    update();
    // Rebuild every cached GetWidget/GetBuilder so screens repaint with the
    // new AppColors getters.
    Get.forceAppUpdate();
  }

  void _applySystemMode() {
    Get.changeThemeMode(AppColors.isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
