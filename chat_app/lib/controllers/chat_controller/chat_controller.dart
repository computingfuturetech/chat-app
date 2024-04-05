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
    // checkMicrophonePermission();
    localDatabaseService.initDatabase();
  }

  final baseUrl = 'https://52b6-182-185-212-155.ngrok-free.app/chat';

  checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  checkStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      await Permission.storage.request();
    }
  }

  checkMicrophonePermission() async {
    var status = await Permission.microphone.status;

    if (status.isDenied) {
      await Permission.microphone.request();
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

  void init(String chatRoomId, String userId) {
    getToken();
    log('chatRoomId: $chatRoomId, userId: $userId');

    channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://52b6-182-185-212-155.ngrok-free.app/ws/chat/$chatRoomId/$userId/'),
    );
    update();
    localDatabaseService
        .initDatabase()
        .then((value) => !isDbOpen ? isDbOpen = true : null)
        .then((_) {
      // Ensure UI update after database initialization
      update();
    });

    channel.stream.listen((event) {
      var data = json.decode(event);
      userId = data['user_id'];
      log('value: $data');

      if (data['message'] == null && data['image'] != null) {
        localDatabaseService
            .insertMessage(ChatMessage(
                content: event.toString(),
                sender: 'Other',
                timestamp: DateTime.now()))
            .then((_) {
          // Ensure UI update after inserting new message
          update();
        });
        return;
      }

      localDatabaseService
          .insertMessage(ChatMessage(
              content: event.toString(),
              sender: 'Other',
              timestamp: DateTime.now()))
          .then((_) {
        // Ensure UI update after inserting new message
        update();
      });
    });
  }

  void sendMessage(String message) {
    if (message.isNotEmpty) {
      channel.sink.add(
        jsonEncode({
          'type': 'text_type',
          'username': 'username', // Set your username here
          'message': message,
        }),
      );

      localDatabaseService.insertMessage(ChatMessage(
          content: message, sender: 'Me', timestamp: DateTime.now()));

      messageController.clear();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    channel.sink.close();
    super.onClose();
  }
}
