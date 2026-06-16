import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/controllers/auth/register_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/enum_helper.dart';
import 'package:travel_app/helpers/validator_helper.dart';
import 'package:travel_app/views/auth/login_screen.dart';
import 'package:travel_app/views/auth/widgets/auth_layout.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller = Get.find<RegisterController>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    final hScale = authVScale(context);
    double v(double base) => base * hScale;

    return AuthScaffold(
      children: [
        const AuthHeroBadge(icon: Icons.person_add_alt_1_rounded),
        SizedBox(height: v(32)),
        AuthTitle(
          title: "register".tr,
          subtitle: "Create your account to start exploring destinations.",
        ),
        SizedBox(height: v(32)),
        Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AuthFieldLabel("full_name".tr),
              SizedBox(height: v(8)),
              CustomField(
                hint: "full_name".tr,
                controller: controller.name,
                fillColor: k_fieldGray,
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: k_primaryColor,
                  size: 22,
                ),
                validator: (value) {
                  return ValidatorHelper.instance.validator(
                    value: controller.name.text,
                    type: FieldType.name,
                  );
                },
                hintText: '',
                readOnly: false,
              ),
              SizedBox(height: v(18)),
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
                validator: (value) {
                  return ValidatorHelper.instance.validator(
                    value: controller.email.text,
                    type: FieldType.email,
                  );
                },
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
                validator: (value) {
                  return ValidatorHelper.instance.validator(
                    value: controller.password.text,
                    type: FieldType.password,
                  );
                },
                hintText: '',
                readOnly: false,
              ),
              SizedBox(height: v(18)),
              AuthFieldLabel("confirm_password".tr),
              SizedBox(height: v(8)),
              CustomField(
                hint: "confirm_password".tr,
                controller: controller.confirmPassword,
                fillColor: k_fieldGray,
                obscureText: _obscureConfirm,
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: k_primaryColor,
                  size: 22,
                ),
                suffixIcon: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF7A869A),
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirm = !_obscureConfirm);
                  },
                ),
                validator: (value) {
                  return ValidatorHelper.instance.validator(
                    value: controller.confirmPassword.text,
                    matchText: controller.password.text,
                    type: FieldType.confirmPassword,
                  );
                },
                hintText: '',
                readOnly: false,
              ),
            ],
          ),
        ),
        SizedBox(height: v(28)),
        GetBuilder<RegisterController>(
          builder: (c) => AuthPrimaryButton(
            label: "register".tr,
            isLoading: c.isLoading,
            onPressed: () async => await c.createAccount(),
          ),
        ),
        SizedBox(height: v(24)),
        AuthFooterSwitch(
          leading: "have_account".tr,
          action: "login_button".tr,
          onTap: () async {
            await Get.off(() => LoginScreen());
            Get.find<RegisterController>().onClose();
          },
        ),
        SizedBox(height: v(12)),
      ],
    );
  }
}
