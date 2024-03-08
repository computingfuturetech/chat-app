import 'package:chat_app/utils/exports.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<AuthController>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Enter the OTP sent to your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: carosBold,
                ),
              ),
              const SizedBox(height: 20),
              OtpTextField(
                numberOfFields: 6,
                clearText: true,
                enabledBorderColor: primartColor,
                focusedBorderColor: primartColor,
                borderColor: secondaryFontColor,
                //set to true to show as box or false to show as dash
                showFieldAsBox: true,
                //runs when a code is typed in
                onCodeChanged: (String code) {
                  //handle validation or checks here
                  controller.otpController.text = code;
                },
                //runs when every textfield is filled
                onSubmit: (String verificationCode) {
                  //handle validation or checks here
                  controller.otpController.text = verificationCode;
                  controller.verifyOTP();
                }, // end onSubmit
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  // Resend OTP
                  controller.sendPasswordResetEmail();
                },
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: secondaryFontColor,
                    fontSize: 16,
                    fontFamily: circularStdBold,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),
              LargeButton(
                controller: controller,
                title: 'Verify OTP',
                onPressed: () {
                  controller.verifyOTP();
                },
                backgroundColor: secondaryFontColor,
                textColor: whiteColor,
              )
            ],
          ),
        ),
      ),
    );
  }
}
