import 'package:chat_app/utils/exports.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AuthController>();
    final formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: carosBold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter your email address we will send you an OTP to reset your password',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: greyColor,
                      fontSize: 16,
                      fontFamily: circularStdBook,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: InputField(
                      label: email,
                      hintText: emailHint,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                    ),
                  ),
                ],
              ),
              LargeButton(
                controller: controller,
                title: 'Send OTP',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    controller.sendPasswordResetEmail();
                  }
                },
                backgroundColor: secondaryFontColor,
                textColor: whiteColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
