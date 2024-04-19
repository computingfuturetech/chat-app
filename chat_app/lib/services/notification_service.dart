import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  initNotification() async {
    // ignore: unused_local_variable
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<String?> getFCMToken() async {
    final token = await messaging.getToken();
    return token;
  }

}
