import 'dart:developer';
import 'dart:io';

import 'package:chat_app/utils/exports.dart';
import 'package:file_picker/file_picker.dart';

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

  // final baseUrl = '$baseUrl/chat';

  checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      await Permission.camera.request();
    }
  }

  PermissionStatus? _permissionStatus;

  Future<void> checkStoragePermission() async {
    if (_permissionStatus != null &&
        _permissionStatus == PermissionStatus.granted) {
      return; // Permission already granted, do nothing
    }

    _permissionStatus = await Permission.storage.request();

    if (_permissionStatus == PermissionStatus.granted) {
      log('Storage Permission granted');
    } else if (_permissionStatus == PermissionStatus.denied) {
      _permissionStatus = await Permission.storage.request();
      _permissionStatus = await Permission.audio.request();
      _permissionStatus = await Permission.camera.request();
      _permissionStatus = await Permission.mediaLibrary.request();
      _permissionStatus = await Permission.manageExternalStorage.request();
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
      // final imageBytes = Uint8List.fromList(bytes);

      // Send the image as a binary message
      channel.sink.add(jsonEncode(
          {'type': 'image_type', 'username': username, 'message': bytes}));
      // channel.sink.add(jsonEncode({'type': 'image_type', 'image': 'bytes'}));
    } catch (e) {
      log('Error sending image: $e');
    }
  }

  filePicker(context, channel, username) async {
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

      final extension = file.path.split('.').last;

      final bytes = await file.readAsBytes();
      log('bytes: $bytes');

      channel.sink.add(jsonEncode({
        'type': 'media_type',
        'username': username,
        'message': bytes,
        'extension': extension
      }));
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

      final extension = file.path.split('.').last;

      // log('bytes: $bytes');

      channel.sink.add(jsonEncode({
        'type': 'document_type',
        'username': username,
        'message': bytes,
        'extension': extension
      }));
      imglink.value = '';
      Get.snackbar('', 'Document Selected');
    } else {
      Get.snackbar('', 'No Document Selected');
    }
  }

  sendMedia(channel, mediaPath, username) async {
    try {
      // Read the image file as bytes
      final file = File(mediaPath);
      final bytes = await file.readAsBytes();

      // Convert bytes to Uint8List
      // final imageBytes = Uint8List.fromList(bytes);

      // Send the image as a binary message
      channel.sink.add(jsonEncode(
          {'type': 'media_type', 'username': username, 'message': bytes}));
      // channel.sink.add(jsonEncode({'type': 'image_type', 'image': 'bytes'}));
    } catch (e) {
      log('Error sending image: $e');
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
