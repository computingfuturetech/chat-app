import 'package:chat_app/utils/exports.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const Text(
                    loginWithEmail,
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: carosBold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    loginWelcome,
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
                            if (controller.passwordRegexExp.hasMatch(value) ==
                                false) {
                              return 'Password is too weak';
                            }
                            return null;
                          },
                          controller: controller.passwordController,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              Column(
                children: [
                  LargeButton(
                    title: login,
                    onPressed: () {
                      if (controller.formKey.currentState!.validate()) {
                        controller.emailController.clear();
                        controller.passwordController.clear();
                        controller.confirmPasswordController.clear();
                        controller.usernameController.clear();
                      }
                    },
                    backgroundColor: controller.email.value.isEmpty ||
                            controller.password.value.isEmpty
                        ? greyColor
                        : secondaryFontColor,
                    textColor: whiteColor,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Get.to(() => const ForgotPasswordScreen(),
                          transition: Transition.rightToLeft);
                    },
                    child: const Text(
                      forgotPassword,
                      style: TextStyle(
                        color: secondaryFontColor,
                        fontSize: 14,
                        fontFamily: circularStdMedium,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
