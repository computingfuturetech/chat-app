import 'package:chat_app/utils/exports.dart';

class OTPVerificationScreen extends StatelessWidget {
  const OTPVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              borderColor: secondaryFontColor,
              //set to true to show as box or false to show as dash
              showFieldAsBox: true,
              //runs when a code is typed in
              onCodeChanged: (String code) {
                //handle validation or checks here
              },
              //runs when every textfield is filled
              onSubmit: (String verificationCode) {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Verification Code"),
                        content: Text('Code entered is $verificationCode'),
                      );
                    });
              }, // end onSubmit
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () {
                // Resend OTP
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
              title: 'Verify OTP',
              onPressed: () {
                Get.to(() => const ChangePasswordScreen(),
                    transition: Transition.rightToLeft);
              },
              backgroundColor: secondaryFontColor,
              textColor: whiteColor,
            )
          ],
        ),
      ),
    );
  }
}
