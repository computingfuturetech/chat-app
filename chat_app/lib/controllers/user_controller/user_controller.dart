import 'dart:developer';
import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:http/http.dart' as http;

class UserController extends GetxController {
  final authController = Get.find<AuthController>();
  final users = <User>[].obs;

  // final baseUrl = '$baseUrl/user';
  final token = ''.obs;
  final isHomeSearch = false.obs;
  final contactSearchController = TextEditingController();
  final requestSearchController = TextEditingController();
  final isContactSearch = false.obs;
  final _localDatabaseService = LocalDatabaseService();
  final isWriting = false.obs;

  final isHomeScreenLoading = false.obs;

  final RxInt aiChatRoomIds = 0.obs;

  final chatRoomsList = <Chatroom>[].obs;

  final toId = ''.obs;
  final fromId = ''.obs;

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

      final url = Uri.parse('$baseUrl/user/list_of_user/');
      final response = await http.get(url, headers: header);

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
      final url = Uri.parse('$baseUrl/user/list_of_user/?search=$value');
      final response = await http.get(url, headers: header);

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
      final url = Uri.parse('$baseUrl/user/list_of_user/?search=$value');
      final response = await http.get(url, headers: header);

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
      final url = Uri.parse('$baseUrl/user/friend-request/receive/');
      final response = await http.get(url, headers: header);

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

  Stream<List<Chatroom>> fetchChatRoomsData() async* {
    try {
      await _localDatabaseService.ensureInitialized();

      // Fetch data from local database
      final localData = await _localDatabaseService.fetchChatRoomsData().first;
      chatRoomsList.assignAll(localData);

      // Fetch data from API in the background
      await _fetchDataFromApiInBackground();

      // Yield the updated list
      yield chatRoomsList.toList();
    } catch (e) {
      throw 'Error fetching chat rooms data: $e';
    }
  }

  Future<void> _fetchDataFromApiInBackground() async {
    try {
      isHomeScreenLoading.value = true;
      final bool isConnected = await checkInternetConnectivity();

      if (isConnected) {
        final header = {
          'Authorization': 'JWT ${token.value}',
        };
        final url = Uri.parse('$baseUrl/chat/chatrooms/');

        final response = await http.get(url, headers: header);

        if (response.statusCode == 200) {
          final responseBody = response.body;
          if (responseBody.isNotEmpty) {
            final List<Chatroom> chatRooms = chatroomFromJson(responseBody);
            chatRoomsList.assignAll(chatRooms);
            log('Chatrooms from API: ${chatRoomsList.first.lastMessage.message}');
            await _localDatabaseService.updateChatRooms(chatRooms);
            isHomeScreenLoading.value = false;
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
    // getAIChatroom();
  }

  Future<void> sendFriendRequestNotification(String id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final userID = prefs.getString('id');
      final WebSocketChannel channel = WebSocketChannel.connect(
        Uri.parse('$webSocketUrl/ws/notification/$id/'),
        // 'ws://52b6-182-185-212-155.ngrok-free.app/ws/notification/${toId.value}/${fromId.value}/'),
      );
      channel.stream.listen((event) {
        // Retrieve the message from the WebSocket channel
        // final String receivedMessage = message['message'] ?? '';
        // log('Received message: $receivedMessage');

        // Show a notification with the received message
        // _showNotificationWithDefaultSound(msg);
      }, onError: (error) {
        // Handle WebSocket errors
        log('WebSocket error: $error');
      }, onDone: () {
        // Handle WebSocket close
        log('WebSocket closed');
      });
      channel.sink.add(jsonEncode({
        'type': 'friend_request_type',
        'userID': userID,
        'message':
            'sent you Friend Request', // Pass the message parameter here,
      }));

      // Handle WebSocket events
      // channel.stream.listen((message) {
      //   // Handle incoming messages
      //   log('WebSocket message received: $message');

      //   // Call the `FlutterBackgroundService().invoke('setAsForeground')` method to show a notification.
      // FlutterBackgroundService().invoke('setAsForeground');
      // FlutterBackgroundService().invoke('setAsForeground', {'fromId': fromId.value, 'toId': toId.value});
      // FlutterBackgroundService().invoke('setAsForeground', {
      //   'data': {
      //     'fromId': fromId.value,
      //     'toId': toId.value,
      //     'authId': authController.userid.toString()
      //   }
      // });

      //   // _showNotificationWithDefaultSound(message.toString());
      // }, onError: (error) {
      //   // Handle WebSocket errors
      //   log('WebSocket error: $error');
      // }, onDone: () {
      //   // Handle WebSocket close
      //   log('WebSocket closed');
      // });
    } catch (e) {
      log('Error in WebSocket communication: $e');
      throw 'Error: $e';
    }
  }

  // Future _showNotificationWithDefaultSound(String message) async {
  //   // Initialise the plugin of flutterlocalnotifications.
  //   FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

  //   // App_icon needs to be added as a drawable resource to the Android head project.
  //   var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iOS = const DarwinInitializationSettings(
  //       requestAlertPermission: true,
  //       requestBadgePermission: true,
  //       requestSoundPermission: true);

  //   // Initialise settings for both Android and iOS device.
  //   var settings = InitializationSettings(android: android, iOS: iOS);
  //   flip.initialize(settings);

  //   // Show a notification with the received message
  //   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );
  //   var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
  //     sound: 'default',
  //     subtitle: 'subtitle',
  //   );

  //   // Initialise channel platform for both Android and iOS device.
  //   var platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //   await flip.show(
  //     0,
  //     'Notification',
  //     message,
  //     platformChannelSpecifics,
  //     payload: 'Default_Sound',
  //   );
  // }

  sendFriendRequest(int id) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/user/friend_request/send/');
      final body = {'to_user': '$id'};
      toId.value = id.toString();
      fromId.value = authController.userid.toString();
      final response = await http.post(url, headers: header, body: body);

      await sendFriendRequestNotification(id.toString());
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Friend request sent');
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      log('Error in sending friend request: $e');
      throw 'Error: $e';
    }
  }

  acceptFriendRequest(int id) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };

      final url = Uri.parse('$baseUrl/user/friend-request/accept/');
      final body = {'from_user': '$id'};
      final response = await http.put(url, headers: header, body: body);

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
      final url = Uri.parse('$baseUrl/user/list_of_user/');
      final response = await http.get(url, headers: header);

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
    }).then((value) => getAIChatroom());
  }

  getAIChatroom() async {
    log('getAIChatroom');
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/chat/chatrooms/ai');

      final response = await http.get(url, headers: header);

      if (response.statusCode == 200) {
        final List<dynamic> responseJson = jsonDecode(response.body);
        log('getAIChatrooms: $responseJson');

        if (responseJson.isNotEmpty && responseJson[0].containsKey('id')) {
          final dynamic chatRoomId = responseJson[0]['id'];
          if (chatRoomId is int) {
            log('AI Chatroom ID: $chatRoomId');
            aiChatRoomIds.value = chatRoomId;
          } else if (chatRoomId is String) {
            // Convert the string to an integer
            final int aiChatRoomId = double.parse(chatRoomId).toInt();
            // log('AI Chatroom ID: $aiChatRoomId');
            aiChatRoomIds.value = aiChatRoomId;
            log('AI Chatroom ID RxInt: ${aiChatRoomIds.value}');
          } else {
            throw 'Unexpected type for chat_room_id: ${chatRoomId.runtimeType}';
          }
        } else {
          throw 'chat_room_id key not found or response is empty';
        }
      } else {
        throw 'Failed to load data';
      }
    } catch (e) {
      log('Error from AI: $e');
    }
  }
}
