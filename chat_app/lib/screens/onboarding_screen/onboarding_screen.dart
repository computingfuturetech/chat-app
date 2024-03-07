import 'package:chat_app/utils/exports.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              blackColor,
              gradientColor,
              blackColor,
              blackColor,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Image.asset(logo),
              const SizedBox(height: 20),
              const Column(
                children: [
                  Text(
                    'Connect friends',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 68,
                      fontFamily: carosRegular,
                    ),
                  ),
                  Text(
                    'easily and quickly',
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: 68,
                      fontFamily: carosRegular,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Our chat app is the perfect way to stay connected with friends and family.',
                style: TextStyle(
                  color: greyColor,
                  fontSize: 16,
                  fontFamily: circularStdBook,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    padding: const EdgeInsets.all(5),
                    height: 60,
                    decoration: BoxDecoration(
                      // color: whiteColor,
                      border: Border.all(
                        color: whiteColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10000),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Image.asset(facebook),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.all(5),
                    height: 60,
                    decoration: BoxDecoration(
                      // color: whiteColor,
                      border: Border.all(
                        color: whiteColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10000),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Image.asset(google),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    width: 60,
                    padding: const EdgeInsets.all(5),
                    height: 60,
                    decoration: BoxDecoration(
                      // color: whiteColor,
                      border: Border.all(
                        color: whiteColor,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10000),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Image.asset(appleLogo),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 2.45,
                    decoration: const BoxDecoration(
                      color: greyColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'OR',
                    style: TextStyle(
                      color: greyColor,
                      fontSize: 14,
                      fontFamily: circularStdBook,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 2.45,
                    decoration: const BoxDecoration(
                      color: greyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              LargeButton(
                title: signupWithEmail,
                onPressed: () {
                  Get.offAll(() => const SignUpScreen(),
                      transition: Transition.zoom);
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Get.offAll(() => const LoginScreen(),
                      transition: Transition.zoom);
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Existing account? ',
                      style: TextStyle(
                        color: greyColor,
                        fontSize: 16,
                        fontFamily: circularStdBook,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Login',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 16,
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
      ),
    );
  }
}
