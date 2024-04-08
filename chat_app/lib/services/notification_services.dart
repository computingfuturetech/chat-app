import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // This is the wake lock configuration.
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // This is the configuration for iOS.
      autoStart: true,
      // You can set `isForeground` to true if you want to display notifications
      // as foreground.
    ),
  );
}

void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // This will register a callback for flutterLocalNotificationsPlugin.
  service.on('setAsForeground').listen((data) async {
    log('data: $data');

    final Map<String, dynamic> dataMap = data as Map<String, dynamic>;
    log('dataMap: $dataMap');

// Access the inner map stored in the 'data' field
    final Map<String, dynamic> innerDataMap =
        dataMap['data'] as Map<String, dynamic>;
    log('innerDataMap: $innerDataMap');

    final jsonData = jsonEncode(innerDataMap);
    final decodedJsonData = jsonDecode(jsonData);
    log('jsonData: $decodedJsonData');

    final fromId = decodedJsonData['fromId'];
    final toId = decodedJsonData['toId'];
    final authId = decodedJsonData['authId'];
    log('fromId: $fromId');
    log('toId: $toId');

    log('setAsForeground');
    const androidChannelId = "com.computingfuturetech.chat_app";
    const id = 0;
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        androidChannelId,
        'Simple App',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      ),
      iOS: DarwinNotificationDetails(),
    );

    final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('ws://4077-119-73-114-193.ngrok-free.app/ws/notification/2/5/'),
      // 'ws://52b6-182-185-212-155.ngrok-free.app/ws/notification/$toId/$fromId/'),
    );

    // if (fromId.toString() == authId.toString()) {
    // log('Same user id');
    //  await flutterLocalNotificationsPlugin.show(
    //   id,
    //   'Friend Request Sent',
    //   'Successfully sent Friend Request', // Pass the message here
    //   notificationDetails,
    //   payload: 'Simple Notification',
    // );
    //   return;
    // }

    channel.stream.listen((message) async {
      // Retrieve the message from the WebSocket channel
      log('WebSocket message: $message');
      final decodedMessage = jsonDecode(message);
      final msg = decodedMessage['message'] ?? '';
      // final String receivedMessage = message['message'] ?? '';
      // log('Received message: $receivedMessage');

      // Show a notification with the received message
      await flutterLocalNotificationsPlugin.show(
        id,
        'New Friend Request',
        msg, // Pass the message here
        notificationDetails,
        payload: 'Simple Notification',
      );
    }, onError: (error) {
      // Handle WebSocket errors
      log('WebSocket error: $error');
    }, onDone: () {
      // Handle WebSocket close
      log('WebSocket closed');
    });

    // Retrieve the message from the data

    // This will make the service stay in the foreground.
    // service.setAsForeground();
  });

  // It will invoke whenever you call `FlutterBackgroundService().invoke('stopService')`.
  service.on('stopService').listen((data) {
    // service.stop();
  });
}
