import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/controllers/profile/profile_controller.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/models/user_model.dart';
import 'package:travel_app/network/database_service.dart';
import 'package:travel_app/network/firestorage_service.dart';

class EditAccountController extends GetxController {
  UserModel model = MainUser.instance.model!;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoading = false;

  File? image;
  String? imagePath;

  late TextEditingController name;
  late TextEditingController location;
  late TextEditingController address;
  late TextEditingController phoneNumbner;

  @override
  void onInit() {
    super.onInit();
    name = TextEditingController(text: model.name);
    location = TextEditingController(text: model.location);
    address = TextEditingController(text: model.address);
    phoneNumbner = TextEditingController(text: model.phoneNumber.toString());
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      imagePath = picked.path;
      image = File(picked.path);
    }
    update();
  }

  Future<String?> uploadImage() async {
    if (image == null) return null;
    return await FireStorageService.instance.uploadImage(image!);
  }

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    update();

    try {
      String? imageUrl;
      if (image != null) imageUrl = await uploadImage();

      final updated = UserModel(
        uId: model.uId,
        email: model.email,
        address: address.text,
        name: name.text,
        location: location.text,
        phoneNumber: int.parse(phoneNumbner.text),
        image: imageUrl ?? model.image,
      );

      await DatabaseService.instance.updateUser(updated);
      await CatchStorage.save(k_userKey, jsonEncode(updated.toMap));
      MainUser.instance.update();

      Get.back();
      Get.find<ProfileController>().update();

      isLoading = false;
      update();
    } catch (error) {
      isLoading = false;
      update();
      Get.snackbar(
        "Something_wrong".tr,
        error.toString(),
        backgroundColor: Colors.red,
      );
    }
  }
}
