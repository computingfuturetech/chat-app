import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/utils/exports.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final otpController = TextEditingController();
  var signupFormKey = GlobalKey<FormState>();
  var loginFormKey = GlobalKey<FormState>();
  final isLoading = false.obs;
  final passwordRegex = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
  final token = ''.obs;
  final userid = ''.obs;

  RegExp get passwordRegexExp => RegExp(passwordRegex);

  final baseURL = 'http://192.168.0.115:8000/user';

  signup() async {
    try {
      isLoading(true);
      final email = emailController.text.toLowerCase().trim();
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (email.isEmpty ||
          username.isEmpty ||
          password.isEmpty ||
          confirmPassword.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'username': username,
        'password': password,
      };
      var url = Uri.parse('$baseURL/create/');
      var response = await http.post(url, body: data);
      var responseJson = json.decode(response.body);

      if (response.statusCode == 201) {
        isLoading(false);

        Get.snackbar('Success', responseJson['status']);
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();

        Get.offAll(() => LoginScreen(), transition: Transition.rightToLeft);
      } else if (response.statusCode == 400) {
        Get.snackbar('Error', responseJson['status']);
      } else if (response.statusCode == 500) {
        if (responseJson['error'].toString().contains('password')) {
          Get.snackbar('Error', 'Password must be at least 8 characters');
        } else if (responseJson['error'].toString().contains('email')) {
          Get.snackbar('Error', 'Email valid email address');
        } else if (responseJson['error'].toString().contains('username')) {
          Get.snackbar('Error', 'Username must be at least 5 characters');
        } else {
          Get.snackbar('Error', 'Something went wrong');
        }
      }
      isLoading(false);
    } catch (e) {
      log('Error: $e');
      isLoading(false);
    }
    isLoading(false);
  }

  login() async {
    try {
      isLoading(true);
      final email = emailController.text.toLowerCase().trim();
      final password = passwordController.text.trim();
      final prefs = await SharedPreferences.getInstance();

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'password': password,
      };
      var url = Uri.parse('$baseURL/login/');
      var response = await http.post(url, body: data);
      var responseJson = json.decode(response.body);
      log('Response JSON: $responseJson');
      if (response.statusCode == 200) {
        Get.snackbar('Success', responseJson['status']);
        isLoading(false);

        prefs.setString('token', responseJson['token']);
        prefs.setString('user_id', responseJson['user_id'].toString());
        emailController.clear();
        passwordController.clear();
        Get.offUntil(GetPageRoute(page: () => const Home()), (route) => false);
      } else if (response.statusCode == 400) {
        isLoading(false);

        Get.snackbar('Error', responseJson['status']);
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', responseJson['error']);
        isLoading(false);
      } else if (response.statusCode == 500) {
        Get.snackbar('Error', 'Something went wrong');
        isLoading(false);
      }
    } catch (e) {
      log('Error: $e');
      isLoading(false);
    }
  }

  sendPasswordResetEmail() async {
    try {
      isLoading(true);
      final email = emailController.text.toLowerCase().trim();

      if (email.isEmpty) {
        Get.snackbar('Error', 'Email is required');
        return;
      }

      var data = {
        'email': email,
      };
      var url = Uri.parse('$baseURL/send-otp/');
      var response = await http.post(url, body: data);
      var responseJson = json.decode(response.body);
      log('Response JSON: $responseJson');

      if (response.statusCode == 201) {
        Get.snackbar('Success', responseJson['status']);
        Get.to(() => const OTPVerificationScreen(),
            transition: Transition.rightToLeft);
      } else if (response.statusCode == 401) {
        Get.snackbar('Error', responseJson['error']);
      } else if (response.statusCode == 500) {
        Get.snackbar('Error', 'Something went wrong');
      } else {
        Get.snackbar('Error', 'Something went wrong');
      }
    } catch (e) {
      log('Error: $e');
    }
    isLoading(false);
  }

  verifyOTP() async {
    try {
      isLoading(true);
      final email = emailController.text.toLowerCase().trim();
      final otp = otpController.text.trim();
      log(otp);

      if (email.isEmpty || otp.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'otp': otp,
      };
      var url = Uri.parse('$baseURL/verify-otp/');
      var response = await http.post(url, body: data);
      log('ResponseCode JSON: ${response.statusCode}');
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
        log('Response JSON: $responseJson');
        Get.snackbar('Success', responseJson['message']);
        otpController.clear();
        Get.to(() => const ChangePasswordScreen(),
            transition: Transition.rightToLeft);
      } else {
        Get.snackbar('Error', 'Invalid OTP');
      }
    } catch (e) {
      log('Error: $e');
    }
    isLoading(false);
  }

  resetPassword() async {
    try {
      isLoading(true);
      final email = emailController.text.toLowerCase().trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      };
      var url = Uri.parse('$baseURL/forget-password/');
      var response = await http.put(url, body: data);
      var responseJson = json.decode(response.body);
      log('Response JSON: $responseJson');
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Password reset successfully');
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
      } else {
        Get.snackbar('Error', 'Something went wrong');
      }
    } catch (e) {
      log('Error: $e');
    }
    isLoading(false);
  }

  logout() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove('token');
      sharedPreferences.remove('user_id');
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      userid.value = '';
      token.value = '';

      Get.offUntil(GetPageRoute(page: () => LoginScreen()), (route) => false);
    } catch (e) {
      log(e.toString());
      Get.snackbar('Error', e.toString());
    }
  }

  authWithGoogleDjango() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final googleSignIn = GoogleSignIn(scopes: ['email']);
      final googleSignInAccount = await googleSignIn.signIn();
      final googleSignInAuthentication =
          await googleSignInAccount?.authentication;
      final accessToken = googleSignInAuthentication?.accessToken;
      final idToken = googleSignInAuthentication?.idToken;
      log('Access Token: $accessToken');
      log('ID Token: $idToken');
      final url = Uri.parse('$baseURL/google/');
      final response = await http.post(url, body: {
        'access_token': accessToken,
        // 'id_token': idToken,
      });
      final responseJson = json.decode(response.body);
      log('Response JSON: $responseJson');
      if (response.statusCode == 200) {
        prefs.setString('token', responseJson['token']);
        prefs.setString('user_id', responseJson['user_id'].toString());
        Get.offUntil(GetPageRoute(page: () => const Home()), (route) => false);
      } else {
        Get.snackbar('Error', responseJson['error']);
      }
    } catch (e) {
      log('Error: $e');
    }
    isLoading(false);
  }

  // authWithFacebookDjango() async {
  //   try {
  //     isLoading(true);
  //     final prefs = await SharedPreferences.getInstance();
  //     final facebookLogin = FacebookLogin();
  //     final result = await facebookLogin.logIn(['email']);
  //     final accessToken = result.accessToken.token;
  //     log('Access Token: $accessToken');
  //     final url = Uri.parse('$baseURL/facebook/');
  //     final response = await http.post(url, body: {
  //       'access_token': accessToken,
  //     });
  //     final responseJson = json.decode(response.body);
  //     log('Response JSON: $responseJson');
  //     if (response.statusCode == 200) {
  //       prefs.setString('token', responseJson['token']);
  //       prefs.setString('user_id', responseJson['user_id'].toString());
  //       Get.offUntil(GetPageRoute(page: () => const Home()), (route) => false);
  //     } else {
  //       Get.snackbar('Error', responseJson['error']);
  //     }
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  //   isLoading(false);
  // }

  // authWithFacebookDjango() async {
  //   try {
  //     isLoading(true);
  //     final prefs = await SharedPreferences.getInstance();
  //     final LoginResult result = await FacebookAuth.instance.login();
  //     final AccessToken? accessToken = result.accessToken;
  //     log('Access Token: $accessToken');
  // final url = Uri.parse('$baseURL/facebook/');
  // final response = await http.post(url, body: {
  //   'access_token': accessToken?.token,
  // });
  // final responseJson = json.decode(response.body);
  // log('Response JSON: $responseJson');
  // if (response.statusCode == 200) {
  //   prefs.setString('token', responseJson['token']);
  //   prefs.setString('user_id', responseJson['user_id'].toString());
  //   Get.offUntil(GetPageRoute(page: () => const Home()), (route) => false);
  // } else {
  //   Get.snackbar('Error', responseJson['error']);
  // }
  //   } catch (e) {
  //     log('Error: $e');
  //   }
  //   isLoading(false);
  // }
}
