import 'dart:developer';
import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/models/user_model/user_model.dart';
import 'package:chat_app/services/chat_message_database_service.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  final users = <User>[].obs;

  final baseUrl = 'https://2121-182-185-212-155.ngrok-free.app/user';
  final token = ''.obs;
  final isHomeSearch = false.obs;
  final contactSearchController = TextEditingController();
  final requestSearchController = TextEditingController();
  final isContactSearch = false.obs;
  final _localDatabaseService = LocalDatabaseService();
  final isWriting = false.obs;

  void setIsWriting(bool value) {
    isWriting.value = value;
  }

  // final List<Chatroom> sampleChatRooms = [
  //   Chatroom(
  //     chatRoomId: '1',
  //     chatType: 'one_to_one',
  //     memberCount: 2,
  //     membersInfo: [
  //       MembersInfo(
  //         id: 3,
  //         firstName: 'DEFAULTER',
  //         lastName: 'GAMING',
  //         bio: 'Hey there! i am using chatbox',
  //         image: '/media/store/images/3pfp.jpg',
  //       ),
  //     ],
  //     lastMessage: LastMessage(
  //       message: 'Hello!',
  //       userId: 2,
  //       timestamp: '2024-03-26T20:58:48.210050',
  //     ),
  //   ),
  //   // Add more sample Chatroom objects if needed
  // ];

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

  fetchContactSearchData(String value) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/list_of_user/?search=$value');
      final response = await http.get(url, headers: header);

      log(response.body);
      if (response.statusCode == 200) {
        final List<User> userList = userFromJson(response.body);
        users.value = userList;
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      throw 'Error: $e';
    }
  }

  fetchRequestSearchData(String value) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/list_of_user/?search=$value');
      final response = await http.get(url, headers: header);

      log(response.body);
      if (response.statusCode == 200) {
        final List<User> userList = userFromJson(response.body);
        users.value = userList;
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

  Future<bool> checkInternetConnectivity() async {
    try {
      final url = Uri.https('google.com');
      var response = await http.head(url);
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Stream<List<Chatroom>> fetchChatRoomsData() async* {
  //   try {
  //     log('fetchChatRoomsData');
  //     await _localDatabaseService.ensureInitialized();
  //     final header = {
  //       'Authorization': 'JWT ${token.value}',
  //     };
  //     final url = Uri.parse(
  //         'https://6160-182-185-201-119.ngrok-free.app/chat/chatrooms/');
  //     final response = await http.get(url, headers: header);
  //     log('reso: ${response.body}');

  //     if (response.statusCode == 200) {
  //       final List<Chatroom> chatRooms = chatroomFromJson(response.body);
  //       await _localDatabaseService.updateChatRooms(chatRooms);
  //       log('Chatrooms data: ${chatRooms[0].membersInfo![0].firstName}');
  //       yield chatRooms;
  //     } else {
  //       throw 'Failed to load data';
  //     }
  //   } catch (e) {
  //     throw 'Error: $e';
  //   }
  // }
  Stream<List<Chatroom>> fetchChatRoomsData() async* {
    try {
      await _localDatabaseService.ensureInitialized();

      // Fetch data from local database
      final localData = await _localDatabaseService.fetchChatRoomsData().first;

      yield localData;

      // Fetch data from API in the background
      _fetchDataFromApiInBackground();
      update();
    } catch (e) {
      throw 'Error fetching chat rooms data: $e';
    }
  }

  // Future<void> _fetchDataFromApiInBackground() async {
  //   try {
  //     final bool isConnected = await checkInternetConnectivity();

  //     if (isConnected) {
  //       final header = {
  //         'Authorization': 'JWT ${token.value}',
  //       };
  //       final url = Uri.parse(
  //           'https://59e2-182-185-217-227.ngrok-free.app/chat/chatrooms/');

  //       final response =
  //           await http.get(url, headers: header).then((value) async {
  //         log('Response: ${value.body}');

  //         if (value.statusCode == 200) {
  //           final List<Chatroom> chatRooms = chatroomFromJson(value.body);
  //           await _localDatabaseService.updateChatRooms(chatRooms);
  //         } else {
  //           throw 'Failed to load data from API';
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     log('Error fetching data from API: $e');
  //   }
  // }
  Future<void> _fetchDataFromApiInBackground() async {
    try {
      final bool isConnected = await checkInternetConnectivity();

      if (isConnected) {
        final header = {
          'Authorization': 'JWT ${token.value}',
        };
        final url = Uri.parse(
            'https://2121-182-185-212-155.ngrok-free.app/chat/chatrooms/');

        final response = await http.get(url, headers: header);

        log('Response: ${response.body}');

        if (response.statusCode == 200) {
          final responseBody = response.body;
          if (responseBody.isNotEmpty) {
            final List<Chatroom> chatRooms = chatroomFromJson(responseBody);
            await _localDatabaseService.updateChatRooms(chatRooms);
          } else {
            throw 'Response body is empty';
          }
        } else {
          throw 'Failed to load data from API';
        }
      }
    } catch (e) {
      log('Error fetching data from API: $e');
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

  getFriendList() async {
    try {
      final header = {
        'Authorization': 'JWT ${token.value}',
      };
      final url = Uri.parse('$baseUrl/list_of_user/');
      final response = await http.get(url, headers: header);

      log(response.body);
      if (response.statusCode == 200) {
        final List<User> userList = userFromJson(response.body);
        users.value = userList;
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
