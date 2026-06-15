import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/components/custom_text.dart';
import 'package:travel_app/controllers/auth/login_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/views/auth/register_screen.dart';
import 'package:travel_app/views/auth/rest_password_screen.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildDecorativeBlobs(size),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildHeroBadge(),
                  const SizedBox(height: 36),
                  CustomText(
                    text: "login".tr,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    text: "Welcome back, sign in to continue your journey.",
                    fontSize: 14,
                    color: const Color(0xFF7A869A),
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 36),
                  _buildFieldLabel("enter_email".tr),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 20),
                  _buildFieldLabel("password".tr),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 32),
                  GetBuilder<LoginController>(
                    builder: (c) => _buildLoginButton(c),
                  ),
                  const SizedBox(height: 28),
                  _buildRegisterRow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeBlobs(Size size) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -size.width * 0.35,
              right: -size.width * 0.3,
              child: Container(
                width: size.width * 0.85,
                height: size.width * 0.85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      k_primaryColor.withOpacity(0.18),
                      k_primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.4,
              left: -size.width * 0.25,
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      k_primaryColor.withOpacity(0.10),
                      k_primaryColor.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            k_primaryColor,
            k_primaryColor.withOpacity(0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: k_primaryColor.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LineIcon.plane(
        color: Colors.white,
        size: 32,
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomText(
        text: text,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF191C32),
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildLoginButton(LoginController c) {
    final isLoading = c.isLoading;
    return Container(
      width: double.infinity,
      height: 57,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: k_primaryColor.withOpacity(isLoading ? 0.0 : 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: k_primaryColor,
          disabledBackgroundColor: k_primaryColor.withOpacity(0.7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: isLoading ? null : () => c.login(),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: "login_button".tr,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(
            text: "not_have_account".tr,
            fontSize: 14,
            color: const Color(0xFF7A869A),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => Get.off(() => RegisterScreen()),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 6,
              ),
              child: CustomText(
                text: "register_button".tr,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: k_primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
