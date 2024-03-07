import 'package:chat_app/utils/exports.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final username = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  final passwordRegex = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  RegExp get passwordRegexExp => RegExp(passwordRegex);

  emailValidation(String? value) async {
    if (value!.isEmpty) {
      return 'Email is required';
    }
    if (GetUtils.isEmail(value) == false) {
      return 'Invalid email';
    }
    return null;
  }
}
