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
import 'package:travel_app/views/auth/user_info_screen.dart';

class RegisterController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();

  bool isLoading = false;

  Future<void> createAccount() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading = true;
      update();

      final response = await AuthService.instance
          .register(email: email.text, password: password.text);
      final user = response.user;
      if (user == null) throw 'Registration failed';

      final _model = UserModel(
        uId: user.id,
        email: user.email,
        name: name.text,
        dateOfRegister: DateFormat("y/M/d ,H:m:s").format(DateTime.now()),
      );

      await DatabaseService.instance.saveUser(_model);
      await CatchStorage.save(k_userKey, jsonEncode(_model.toMap));
      MainUser.instance.update();

      await Get.off(() => const UserInfoScreen());

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
        "Please try again another time".tr,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      );
    }
  }
}
