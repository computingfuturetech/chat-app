import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/input_field.dart';
import 'package:chat_app/widgets/password_input_field.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

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
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  // physics: const BouncingScrollPhysics(),
                  // shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        const Text(
                          signupWithEmail,
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: carosBold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          signUpWelcome,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: greyColor,
                            fontSize: 16,
                            fontFamily: circularStdBook,
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Form(
                          key: controller.formKey,
                          child: Column(
                            children: [
                              InputField(
                                label: name,
                                hintText: nameHint,
                                textCapitalization: TextCapitalization.words,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Name is required';
                                  }

                                  if (value.length < 3) {
                                    return 'Name is too short';
                                  }
                                  return null;
                                },
                                controller: controller.usernameController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              InputField(
                                label: email,
                                hintText: emailHint,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (GetUtils.isEmail(value) == false) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                                controller: controller.emailController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              PasswordInputField(
                                label: password,
                                hintText: passwordHint,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (controller.passwordRegexExp
                                          .hasMatch(value) ==
                                      false) {
                                    return 'Password is too weak';
                                  }
                                  return null;
                                },
                                controller: controller.passwordController,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              PasswordInputField(
                                label: confirmPassword,
                                hintText: confirmPasswordHint,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (controller.password.value !=
                                      controller.confirmPassword.value) {
                                    return 'Password does not match';
                                  }
                                  return null;
                                },
                                controller:
                                    controller.confirmPasswordController,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    LargeButton(
                      title: createAccount,
                      onPressed: () {
                        if (controller.formKey.currentState!.validate()) {
                          controller.emailController.clear();
                          controller.passwordController.clear();
                          controller.confirmPasswordController.clear();
                          controller.usernameController.clear();
                        }
                      },
                      backgroundColor: controller.email.value.isEmpty ||
                              controller.password.value.isEmpty ||
                              controller.confirmPassword.value.isEmpty
                          ? greyColor
                          : secondaryFontColor,
                      textColor: whiteColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
