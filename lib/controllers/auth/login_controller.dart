import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/models/user_model.dart';
import 'package:travel_app/network/auth_service.dart';
import 'package:travel_app/network/database_service.dart';
import 'package:travel_app/views/layout/layout_screen.dart';

class LoginController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    isLoading = true;
    update();

    try {
      final response = await AuthService.instance
          .login(email: email.text, password: password.text);
      final user = response.user;
      if (user == null) throw 'Login failed';

      var userData = await DatabaseService.instance.getUser(user.id);

      if (userData == null) {
        final fallback = UserModel(
          uId: user.id,
          email: user.email ?? email.text,
          name: (user.email ?? email.text).split('@').first,
          dateOfRegister:
              DateFormat("y/M/d ,H:m:s").format(DateTime.now()),
        );
        await DatabaseService.instance.saveUser(fallback);
        userData = fallback.toMap;
      }

      await CatchStorage.save(k_userKey, jsonEncode(userData));
      MainUser.instance.update();

      await Get.off(() => LayoutScreen());

      isLoading = false;
      update();
    } on AuthException catch (error) {
      isLoading = false;
      update();
      Get.closeAllSnackbars();
      Get.snackbar(
        "Something is wrong!".tr,
        error.message,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      );
    } catch (error) {
      isLoading = false;
      update();
      Get.closeAllSnackbars();
      Get.snackbar(
        "Something is wrong!".tr,
        error.toString(),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        duration: const Duration(seconds: 8),
      );
    }
  }
}
