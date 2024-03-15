import 'dart:developer';

import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/models/user_model/user_model.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  final users = <User>[].obs;

  final baseUrl = 'http://192.168.0.189:8000/user';
  final token = ''.obs;

  Stream<List<User>> fetchData() async* {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      log('token: $token');

      final url = Uri.parse('$baseUrl/list_of_user/');
      final response = await http.get(url, headers: header);

      log(response.body);
      if (response.statusCode == 200) {
        final List<User> userList = userFromJson(response.body);
        yield userList;
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  Stream<List<FriendRequest>> fetchRequestData() async* {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/friend-request/receive/');
      final response = await http.get(url, headers: header);
      log('token: $token');

      log(response.body);
      if (response.statusCode == 200) {
        final List<FriendRequest> userList =
            friendRequestFromJson(response.body);
        yield userList;
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  @override
  void onInit() {
    super.onInit();
    getToken();
  }

  sendFriendRequest(int id) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/friend_request/send/');
      final body = {'to_user': '$id'};
      final response = await http.post(url, headers: header, body: body);

      log(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Friend request sent');
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  acceptFriendRequest(int id) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };

      final url = Uri.parse('$baseUrl/friend-request/accept/');
      final body = {'from_user': '$id'};
      final response = await http.put(url, headers: header, body: body);

      log(response.body);
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Friend request accepted');
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  getToken() async {
    SharedPreferences.getInstance().then((prefs) {
      // final bool? isOnboardingDone = prefs.getBool('isOnboardingDone');
      token.value = prefs.getString('token') ?? '';
    });
  }
}
