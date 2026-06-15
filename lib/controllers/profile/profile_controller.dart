import 'package:get/get.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/network/auth_service.dart';
import 'package:travel_app/views/auth/login_screen.dart';

class ProfileController extends GetxController {
  Future<void> logut() async {
    await AuthService.instance.signOut();
    await CatchStorage.remove(k_userKey);
    Get.off(() => LoginScreen());
  }
}
