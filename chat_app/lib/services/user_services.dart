import 'package:shared_preferences/shared_preferences.dart';

class UserServices {
  static getImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('image_url');
  }
}
