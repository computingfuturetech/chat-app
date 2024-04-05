import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/models/user_model/user_model.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class UserController extends GetxController {
  final authController = Get.find<AuthController>();
  final users = <User>[].obs;

  final baseUrl = 'https://52b6-182-185-212-155.ngrok-free.app/user';
  final token = ''.obs;
  final isHomeSearch = false.obs;
  final contactSearchController = TextEditingController();
  final requestSearchController = TextEditingController();
  final isContactSearch = false.obs;
  final _localDatabaseService = LocalDatabaseService();
  final isWriting = false.obs;

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
            'https://52b6-182-185-212-155.ngrok-free.app/chat/chatrooms/');

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

  // Future<void> sendFriendRequestNotification() async {
  //   try {
  //     final WebSocketChannel channel = WebSocketChannel.connect(
  //       Uri.parse(
  //           'ws://52b6-182-185-212-155.ngrok-free.app/ws/notification/3/2/'),
  //     );
  //     log('WebSocket channel created: $channel');
  //     channel.sink.add(jsonEncode(
  //         {'type': 'friend_request_type', 'message': 'Send friend request'}));
  //     log('Message sent via WebSocket');

  //     // Handle WebSocket events
  //     channel.stream.listen((message) {
  //       // Handle incoming messages
  //       log('WebSocket message received: $message');

  //       // Call the `FlutterBackgroundService().invoke('setAsForeground')` method to show a notification.
  //       FlutterBackgroundService().invoke('setAsForeground');

  //       // _showNotificationWithDefaultSound(message.toString());
  //     }, onError: (error) {
  //       // Handle WebSocket errors
  //       log('WebSocket error: $error');
  //     }, onDone: () {
  //       // Handle WebSocket close
  //       log('WebSocket closed');
  //     });
  //   } catch (e) {
  //     log('Error in WebSocket communication: $e');
  //     throw 'Error: $e';
  //   }
  // }
  Future<void> sendFriendRequestNotification() async {
    try {
      final WebSocketChannel channel = WebSocketChannel.connect(
        Uri.parse(
            'ws://52b6-182-185-212-155.ngrok-free.app/ws/notification/2/5/'),
        // 'ws://52b6-182-185-212-155.ngrok-free.app/ws/notification/${toId.value}/${fromId.value}/'),
      );
      channel.stream.listen((event) {
        // Retrieve the message from the WebSocket channel
        log('WebSocket message: $event');
        final decodedMessage = jsonDecode(event);
        final msg = decodedMessage['message'] ?? '';
        // final String receivedMessage = message['message'] ?? '';
        // log('Received message: $receivedMessage');

        // Show a notification with the received message
        _showNotificationWithDefaultSound(msg);
      }, onError: (error) {
        // Handle WebSocket errors
        log('WebSocket error: $error');
      }, onDone: () {
        // Handle WebSocket close
        log('WebSocket closed');
      });
      log('WebSocket channel created: $channel');
      channel.sink.add(jsonEncode({
        'type': 'friend_request_type',
        'message': 'Send friend request', // Pass the message parameter here,
      }));
      log('Message sent via WebSocket');

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

  Future _showNotificationWithDefaultSound(String message) async {
    // Initialise the plugin of flutterlocalnotifications.
    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    // App_icon needs to be added as a drawable resource to the Android head project.
    var android = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    // Initialise settings for both Android and iOS device.
    var settings = InitializationSettings(android: android, iOS: iOS);
    flip.initialize(settings);

    // Show a notification with the received message
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      importance: Importance.high,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      sound: 'default',
      subtitle: 'subtitle',
    );

    // Initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await flip.show(
      0,
      'Notification',
      message,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }

  sendFriendRequest(int id) async {
    try {
      final header = {
        'Authorization': 'JWT $token',
      };
      final url = Uri.parse('$baseUrl/friend_request/send/');
      final body = {'to_user': '$id'};
      toId.value = id.toString();
      fromId.value = authController.userid.toString();
      log('toId: $toId');
      log('fromId: $fromId');
      final response = await http.post(url, headers: header, body: body);

      await sendFriendRequestNotification();
      log(response.body);
      if (response.statusCode == 200) {
        log('Friend request sent successfully');
        Get.snackbar('Success', 'Friend request sent');
      } else {
        log('Failed to send friend request');
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
