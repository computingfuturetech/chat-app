import 'package:chat_app/utils/exports.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setting Screen'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              controller.logout();
            },
            child: const Text('Logout')),
      ),
    );
  }
}
