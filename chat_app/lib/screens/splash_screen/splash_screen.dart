import 'package:chat_app/utils/exports.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Timer(const Duration(seconds: 1), () {
      Get.offAll(() => const OnboardingScreen(), transition: Transition.zoom);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const OnboardingScreen(),
      //   ),
      // );
    });

    return Scaffold(
      body: Center(
        child: Image.asset(splash),
      ),
    );
  }
}
