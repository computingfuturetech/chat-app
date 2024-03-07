import 'package:chat_app/utils/exports.dart';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(backArrow),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Change Password',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontFamily: carosBold,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: formKey,
              child: Column(
                children: [
                  PasswordInputField(
                    label: password,
                    hintText: passwordHint,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                      if (controller.passwordRegexExp.hasMatch(value) ==
                          false) {
                        return 'Password is too weak';
                      }
                      return null;
                    },
                    controller: controller.passwordController,
                  ),
                  const SizedBox(height: 20),
                  PasswordInputField(
                    label: confirmPassword,
                    hintText: confirmPasswordHint,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password is required';
                      }
                      if (controller.passwordController.text != value) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                    controller: controller.confirmPasswordController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LargeButton(
              title: 'Change Password',
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // controller.changePassword();
                }
              },
              backgroundColor: secondaryFontColor,
              textColor: whiteColor,
            ),
          ],
        ),
      ),
    );
  }
}
