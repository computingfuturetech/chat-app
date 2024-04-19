import 'package:chat_app/utils/exports.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
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
                          key: formKey,
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
                              PasswordInputField(
                                label: confirmPassword,
                                hintText: confirmPasswordHint,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (controller.passwordController.value !=
                                      controller
                                          .confirmPasswordController.value) {
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    LargeButton(
                      controller: controller,
                      title: createAccount,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.signup();
                        }
                      },
                      backgroundColor: secondaryFontColor,
                      textColor: whiteColor,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(() => LoginScreen(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Existing account? ',
                            style: TextStyle(
                              color: secondaryFontColor,
                              fontSize: 14,
                              fontFamily: circularStdBook,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Login',
                            style: TextStyle(
                              color: secondaryFontColor,
                              fontSize: 14,
                              fontFamily: circularStdBook,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
