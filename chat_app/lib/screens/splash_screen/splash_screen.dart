import 'package:chat_app/utils/exports.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final authController = Get.put(AuthController());
    Timer(const Duration(seconds: 1), () {
      SharedPreferences.getInstance().then((prefs) {
        // final bool? isOnboardingDone = prefs.getBool('isOnboardingDone');
        final String token = prefs.getString('token') ?? '';
        if (prefs.getString('token') != null && token.isNotEmpty) {
          Get.offAll(() => const Home(), transition: Transition.zoom);
        } else {
          Get.offAll(() => const OnboardingScreen(),
              transition: Transition.zoom);
        }
      });
      // Get.offAll(() => const Home(), transition: Transition.zoom);
    });

    return Scaffold(
      body: Center(
        child: Image.asset(splash),
      ),
    );
  }
}
