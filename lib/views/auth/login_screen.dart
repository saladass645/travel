import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/auth/login_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/auth/register_screen.dart';
import 'package:travel_app/views/auth/rest_password_screen.dart';
import 'package:travel_app/views/auth/widgets/auth_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.find<LoginController>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final hScale = authVScale(context);
    double v(double base) => base * hScale;

    return AuthScaffold(
      children: [
        const AuthHeroBadge(icon: Icons.flight_takeoff_rounded),
        SizedBox(height: v(32)),
        AuthTitle(
          title: "login".tr,
          subtitle: "Welcome back, sign in to continue your journey.",
        ),
        SizedBox(height: v(32)),
        AuthFieldLabel("enter_email".tr),
        SizedBox(height: v(8)),
        CustomField(
          hint: "enter_email".tr,
          controller: controller.email,
          fillColor: k_fieldGray,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: k_primaryColor,
            size: 22,
          ),
          hintText: '',
          readOnly: false,
        ),
        SizedBox(height: v(18)),
        AuthFieldLabel("password".tr),
        SizedBox(height: v(8)),
        CustomField(
          hint: "password".tr,
          controller: controller.password,
          fillColor: k_fieldGray,
          obscureText: _obscurePassword,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: k_primaryColor,
            size: 22,
          ),
          suffixIcon: IconButton(
            splashRadius: 20,
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF7A869A),
              size: 22,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          hintText: '',
          readOnly: false,
        ),
        SizedBox(height: v(12)),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Get.to(() => RestPasswordScreen()),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              child: CustomText(
                text: "forget_password?".tr,
                color: k_primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: v(28)),
        GetBuilder<LoginController>(
          builder: (c) => AuthPrimaryButton(
            label: "login_button".tr,
            isLoading: c.isLoading,
            onPressed: () => c.login(),
          ),
        ),
        SizedBox(height: v(24)),
        AuthFooterSwitch(
          leading: "not_have_account".tr,
          action: "register_button".tr,
          onTap: () => Get.off(() => RegisterScreen()),
        ),
        SizedBox(height: v(12)),
      ],
    );
  }
}
