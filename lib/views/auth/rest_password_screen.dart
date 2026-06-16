import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_app/components/custom_field.dart';
import 'package:travel_app/controllers/auth/rest_password_controller.dart';
import 'package:travel_app/helpers/constants.dart';
import 'package:travel_app/helpers/enum_helper.dart';
import 'package:travel_app/helpers/validator_helper.dart';
import 'package:travel_app/views/auth/widgets/auth_layout.dart';

class RestPasswordScreen extends GetWidget<RestPasswordController> {
  const RestPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hScale = authVScale(context);
    double v(double base) => base * hScale;

    return AuthScaffold(
      showBack: true,
      children: [
        const AuthHeroBadge(icon: Icons.lock_reset_rounded),
        SizedBox(height: v(32)),
        AuthTitle(
          title: "forget_password".tr,
          subtitle: "forget_password_message".tr,
        ),
        SizedBox(height: v(32)),
        Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    value: value,
                    type: FieldType.email,
                  );
                },
                hintText: '',
                readOnly: false,
              ),
            ],
          ),
        ),
        SizedBox(height: v(28)),
        AuthPrimaryButton(
          label: "send".tr,
          onPressed: () async => await controller.sendPasswordResetEmail(),
        ),
        SizedBox(height: v(12)),
      ],
    );
  }
}
