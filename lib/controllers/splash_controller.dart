import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travel_app/helpers/catch_storage.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/main_user.dart';
import 'package:travel_app/views/auth/login_screen.dart';
import 'package:travel_app/views/layout/layout_screen.dart';
import 'package:travel_app/views/on_boarding/on_boarding_screen.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();

    await Future.delayed(Duration(seconds: 2));

    if (CatchStorage.get(k_onBoardingKey) != true) {
      await Get.off(() => OnBoardingScreen());
      return;
    }

    // Trust Supabase, not just the local cache. If the persisted refresh
    // token is stale/expired, currentSession is null after init — fall
    // through to login instead of entering the app with no valid JWT
    // (which surfaces as a 401 on the first Dio call).
    final session = Supabase.instance.client.auth.currentSession;
    final hasLiveSession = session != null && !session.isExpired;

    if (!hasLiveSession || CatchStorage.get(k_userKey) == null) {
      await CatchStorage.remove(k_userKey);
      MainUser.instance.model = null;
      await Get.off(() => LoginScreen());
      return;
    }

    await Get.off(() => LayoutScreen());
  }
}
