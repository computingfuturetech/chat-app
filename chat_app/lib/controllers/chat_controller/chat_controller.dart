import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_model/chat_model.dart';
import 'package:chat_app/services/chat_message_database_service.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatController extends GetxController {
  //variables for image picker
  var imgpath = ''.obs;
  var imglink = ''.obs;
  var token = ''.obs;
  final messageController = TextEditingController();
  final isWriting = false.obs;
  final localDatabaseService = MessageDatabaseService();
  late WebSocketChannel channel;
  bool isDbOpen = false;
  final isDatabaseInitialized = false.obs;

  ChatController() {
    checkCameraPermission();
    checkStoragePermission();
    Future.delayed(Duration.zero, () {
    checkMicrophonePermission();
  });
    localDatabaseService.initDatabase();
  }

  final baseUrl = 'https://4077-119-73-114-193.ngrok-free.app/chat';

  checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  PermissionStatus? _permissionStatus;

  Future<void> checkStoragePermission() async {
    if (_permissionStatus != null && _permissionStatus == PermissionStatus.granted) {
      return; // Permission already granted, do nothing
    }

    _permissionStatus = await Permission.storage.request();

    if (_permissionStatus == PermissionStatus.granted) {
      log('Storage Permission granted');
    } else if (_permissionStatus == PermissionStatus.denied) {
      log('Storage Permission denied');
    } else if (_permissionStatus == PermissionStatus.permanentlyDenied) {
      log('Storage Permission permanently denied, guide user to settings');
      openAppSettings();
    }
  }

 checkMicrophonePermission() async {
  var status = await Permission.microphone.status;

  if (status.isDenied) {
    final newStatus = await Permission.microphone.request();
    if (newStatus.isGranted) {
      // Permission granted, continue with your logic here
    } else if (newStatus.isPermanentlyDenied) {
      // Guide user to app settings
      openAppSettings();
    }
  } else if (status.isGranted) {
    // Permission already granted, continue with your logic here
  }
}

  pickImage(context, source, channel, username) async {
    // Request permissions

    // await Permission.photos.request();
    final PermissionStatus status = await Permission.camera.request();
    // await Permission.storage.request();

    // var status = await Permission.camera.status;
    // Check permission status

    log('inside pick image ${status.isGranted}');

    // Handle status
    if (status.isGranted) {
      // Show picker dialog
      try {
        final img =
            await ImagePicker().pickImage(source: source, imageQuality: 100);

        if (img == null) {
          // User canceled image selection
          return;
        }

        imgpath.value = img.path;
        sendImage(channel, img.path, username);
        // VxToast.show(context, msg: "Image selected");
        Get.snackbar('', 'Image Selected');
      } on PlatformException catch (e) {
        Get.snackbar("Error", e.toString());
      }
    } else {
      if (status.isPermanentlyDenied) {
        // Guide user to app settings
        openAppSettings();
      }
      // Handle denied or permanently denied
      Get.snackbar("Error", "Permission denied");
    }
  }

  sendImage(channel, imagePath, username) async {
    try {
      // Read the image file as bytes
      final file = File(imagePath);
      final bytes = await file.readAsBytes();

      // Convert bytes to Uint8List
      final imageBytes = Uint8List.fromList(bytes);

      // Send the image as a binary message
      channel.sink.add(jsonEncode(
          {'type': 'image_type', 'username': username, 'message': bytes}));
      // channel.sink.add(jsonEncode({'type': 'image_type', 'image': 'bytes'}));
    } catch (e) {
      log('Error sending image: $e');
    }
  }

  filePicker(context) async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      log('inside file picker');
      // await openAppSettings();
      status = await Permission.storage.request();
    }
    log('inside file picker else');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
    );
    if (result != null) {
      File file = File(result.files.single.path!);

      final bytes = await file.readAsBytes();

      channel.sink.add(jsonEncode(
          {'type': 'media_type', 'username': 'username', 'message': bytes}));
      imgpath.value = result.files.single.path!;
      imglink.value = '';
      Get.snackbar('', 'Image Selected');
    } else {
      Get.snackbar('', 'No Image Selected');
    }
  }

  documentPicker(context, channel, username) async {
    var status = await Permission.storage.request();
    if (status.isDenied) {
      log('inside file picker');
      // await openAppSettings();
      status = await Permission.storage.request();
    }
    log('inside file picker else');
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result != null) {
      imgpath.value = result.files.single.path!;
      File file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();

      // log('bytes: $bytes');

      channel.sink.add(jsonEncode(
          {'type': 'document_type', 'username': username, 'message': bytes}));
      imglink.value = '';
      Get.snackbar('', 'Document Selected');
    } else {
      Get.snackbar('', 'No Document Selected');
    }
  }

  getToken() async {
    SharedPreferences.getInstance().then((prefs) {
      // final bool? isOnboardingDone = prefs.getBool('isOnboardingDone');
      token.value = prefs.getString('token') ?? '';
    });
  }

  // void init(String chatRoomId, String userId) {
  //   getToken();
  //   log('chatRoomId: $chatRoomId, userId: $userId');

  //   channel = WebSocketChannel.connect(
  //     Uri.parse(
  //         'ws://192.168.100.7:8000/ws/chat/$chatRoomId/$userId/'),
  //   );
  //   update();
  //   localDatabaseService
  //       .initDatabase()
  //       .then((value) => !isDbOpen ? isDbOpen = true : null)
  //       .then((_) {
  //     // Ensure UI update after database initialization
  //     update();
  //   });

  //   channel.stream.listen((event) {
  //     var data = json.decode(event);
  //     userId = data['user_id'];
  //     log('value: $data');

  //     if (data['message'] == null && data['image'] != null) {
  //       localDatabaseService
  //           .insertMessage(ChatMessage(
  //               id: DateTime.now().millisecondsSinceEpoch,
  //               chatRoomId: chatRoomId,
  //               content: event.toString(),
  //               sender: 'Other',
  //               timestamp: DateTime.now()))
  //           .then((_) {
  //         // Ensure UI update after inserting new message
  //         update();
  //       });
  //       return;
  //     }

  //     localDatabaseService
  //         .insertMessage(ChatMessage(
  //             id: DateTime.now().millisecondsSinceEpoch,
  //             chatRoomId: chatRoomId,
  //             content: event.toString(),
  //             sender: 'Other',
  //             timestamp: DateTime.now()))
  //         .then((_) {
  //       // Ensure UI update after inserting new message
  //       update();
  //     });
  //   });
  // }

  // void sendMessage(String message, String chatRoomId) {
  //   if (message.isNotEmpty) {
  //     channel.sink.add(
  //       jsonEncode({
  //         'type': 'text_type',
  //         'username': 'username', // Set your username here
  //         'message': message,
  //       }),
  //     );

  //     localDatabaseService.insertMessage(ChatMessage(
  //         id: DateTime.now().millisecondsSinceEpoch,
  //         chatRoomId: chatRoomId,
  //         content: message,
  //         sender: 'Me',
  //         timestamp: DateTime.now()));

  //     messageController.clear();
  //   }
  // }

  @override
  void onClose() {
    messageController.dispose();
    channel.sink.close();
    super.onClose();
  }
}
