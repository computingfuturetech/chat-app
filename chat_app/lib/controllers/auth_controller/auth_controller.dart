import 'dart:developer';

import 'package:chat_app/utils/exports.dart';
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

  final username = ''.obs;
  final email = ''.obs;
  final image = ''.obs;
  final phone = ''.obs;
  final bio = ''.obs;

  RegExp get passwordRegexExp => RegExp(passwordRegex);

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
      var url = Uri.parse('$baseUrl/user/create/');
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

      final fcmToken = await NotificationService().getFCMToken();
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
      };
      var url = Uri.parse('$baseUrl/user/login/');
      var response = await http.post(url, body: data);
      var responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('Success', responseJson['status']);
        isLoading(false);

        prefs.setString('token', responseJson['token']);
        prefs.setString('user_id', responseJson['user_id'].toString());
        emailController.clear();
        passwordController.clear();
        getUserDetails();
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
      var url = Uri.parse('$baseUrl/user/send-otp/');
      var response = await http.post(url, body: data);
      var responseJson = json.decode(response.body);

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

      if (email.isEmpty || otp.isEmpty) {
        Get.snackbar('Error', 'All fields are required');
        return;
      }

      var data = {
        'email': email,
        'otp': otp,
      };
      var url = Uri.parse('$baseUrl/user/verify-otp/');
      var response = await http.post(url, body: data);
      if (response.statusCode == 200) {
        var responseJson = json.decode(response.body);
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
      var url = Uri.parse('$baseUrl/user/forget-password/');
      var response = await http.put(url, body: data);
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

  Future<void> deleteLocalDatabase() async {
    try {
      // Get the directory where databases are stored
      var databasesPath = await getDatabasesPath();
      // Construct the path to your database file
      var path = join(databasesPath, 'chat_app_database.db');
      // Check if the database file exists
      bool exists = await databaseExists(path);
      // If the database file exists, delete it
      if (exists) {
        await deleteDatabase(path);
      } else {
        log('Database does not exist');
      }
    } catch (e) {
      log('Error deleting database: $e');
    }
  }

  Future<void> deleteMessagesLocalDatabase() async {
    try {
      // Get the directory where databases are stored
      var databasesPath = await getDatabasesPath();
      // Construct the path to your database file
      var path = join(databasesPath, 'chat_database.db');
      // Check if the database file exists
      bool exists = await databaseExists(path);
      // If the database file exists, delete it
      if (exists) {
        await deleteDatabase(path);
      } else {
        log('Database does not exist');
      }
    } catch (e) {
      log('Error deleting database: $e');
    }
  }

  logout() async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.remove('token');
      sharedPreferences.remove('user_id');
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      sharedPreferences.remove('first_name');
      sharedPreferences.remove('last_name');
      sharedPreferences.remove('email');
      sharedPreferences.remove('image');
      sharedPreferences.remove('phone');
      sharedPreferences.remove('bio');
      deleteLocalDatabase();
      deleteMessagesLocalDatabase();

      userid.value = '';
      token.value = '';

      Get.offUntil(GetPageRoute(page: () => LoginScreen()), (route) => false);
    } catch (e) {
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
      final url = Uri.parse('$baseUrl/user/google/');
      final response = await http.post(url, body: {
        'access_token': accessToken,
      });
      final responseJson = json.decode(response.body);
      if (response.statusCode == 200) {
        prefs.setString('token', responseJson['token']);
        prefs.setString('user_id', responseJson['user_id'].toString());
        userid.value = responseJson['user_id'].toString();
        Get.offUntil(GetPageRoute(page: () => const Home()), (route) => false);
      } else {
        Get.snackbar('Error', responseJson['error']);
      }
    } catch (e) {
      log('Error: $e');
    }
    isLoading(false);
  }

  getUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.getString('token') == null ||
          prefs.getString('token') == '' ||
          prefs.getString('token')!.isEmpty) {
        return;
      }
      final firstName = prefs.getString('first_name');
      if (firstName == null || firstName.isEmpty || firstName == '') {
        try {
          final url = Uri.parse('$baseUrl/user/update/');
          final response = await http.post(url, headers: {
            'Authorization': 'JWT ${prefs.getString('token')}',
          });
          final responseJson = json.decode(response.body);
          if (response.statusCode == 200) {
            if (responseJson.containsKey('first_name')) {
              final firstNameValue = responseJson['first_name'];
              prefs.setString('first_name', firstNameValue ?? '');
              if (responseJson.containsKey('last_name')) {
                final lastNameValue = responseJson['last_name'];
                prefs.setString('last_name', lastNameValue ?? '');
                username.value =
                    '${prefs.getString('first_name')!} ${prefs.getString('last_name')!}';
              }
            }
            if (responseJson.containsKey('email')) {
              final emailValue = responseJson['email'];
              prefs.setString('email', emailValue ?? '');
              email.value = prefs.getString('email')!;
            }
            if (responseJson.containsKey('image')) {
              final imageValue = responseJson['image'];
              prefs.setString('image', imageValue ?? '');
              image.value = '$baseUrl${prefs.getString('image')}';
            }
            if (responseJson.containsKey('phone')) {
              final phoneValue = responseJson['phone'];
              prefs.setString('phone', phoneValue ?? '');
              phone.value = prefs.getString('phone') ?? '';
            }
            if (responseJson.containsKey('bio')) {
              final bioValue = responseJson['bio'];
              prefs.setString('bio', bioValue ?? '');
              bio.value = prefs.getString('bio') ?? '';
            }
            if (responseJson.containsKey('id')) {
              final idValue = responseJson['id'];
              prefs.setString('id', idValue.toString());

              userid.value = prefs.getString('id')!;
            }
          } else {
            Get.snackbar('Error', responseJson['error']);
          }
        } catch (e) {
          log('Error: $e');
        }
      } else {
        username.value =
            '${prefs.getString('first_name')!} ${prefs.getString('last_name')!}';
        email.value = prefs.getString('email')!;
        image.value = '$baseUrl${prefs.getString('image')}';
        phone.value = prefs.getString('phone') ?? '';
        bio.value = prefs.getString('bio') ?? '';
        userid.value = prefs.getString('id')!;
      }
    } catch (e) {
      log('Error: $e');
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    getUserDetails();

    final notificationPermission = await Permission.notification.request();
    if (notificationPermission.isGranted) {
      await NotificationService().initNotification();
    } else {
      await Permission.notification.request();
    }
  }
}
