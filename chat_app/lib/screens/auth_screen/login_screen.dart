import 'package:chat_app/utils/exports.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({
    super.key,
  });

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
        resizeToAvoidBottomInset: false, // Set to true
        body: SizedBox(
          height: MediaQuery.of(context).size.height * 0.86,
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
                      key: formKey,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
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
                      ),
                    )
                  ],
                ),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                Column(
                  children: [
                    LargeButton(
                      controller: controller,
                      title: login,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          controller.login();
                        }
                      },
                      backgroundColor: secondaryFontColor,
                      textColor: whiteColor,
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        Get.to(() => SignUpScreen(),
                            transition: Transition.rightToLeft);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              color: secondaryFontColor,
                              fontSize: 14,
                              fontFamily: circularStdBook,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Sign Up',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
