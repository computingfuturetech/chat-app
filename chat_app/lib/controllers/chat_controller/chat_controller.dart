import 'dart:developer';

import 'package:chat_app/utils/exports.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class ChatController extends GetxController {
  //variables for image picker
  var imgpath = ''.obs;
  var imglink = ''.obs;
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

  pickImage(context, source) async {
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
      imgpath.value = result.files.single.path!;
      imglink.value = '';
      Get.snackbar('', 'Image Selected');
    } else {
      Get.snackbar('', 'No Image Selected');
    }
  }

  documentPicker(context) async {
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
      imglink.value = '';
      Get.snackbar('', 'Document Selected');
    } else {
      Get.snackbar('', 'No Document Selected');
    }
  }
}
