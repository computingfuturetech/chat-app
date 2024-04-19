import 'dart:developer';

import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  showFlutterNotification(message);
  log('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importancechannel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(
  RemoteMessage message, {
  channel,
  localStorage,
  userId,
  authController,
  widget,
}) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    if (notification.title.toString() != 'Friend Request') {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    } else {
      channel.stream.listen((event) async {
        var data = json.decode(event);
        log('data1122: $data');
        userId = data['user_id'];
        log('sender1: $userId');
        if (userId.toString() != authController.userid.toString()) {
          log('user1122: $userId authController.userid: ${authController.userid}');
          log('user1122 not same');
          localStorage
              .insertMessage(ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch,
                  chatRoomId: widget.chatRoomId,
                  content: event.toString(),
                  sender: 'Other',
                  timestamp: DateTime.now()))
              .then((value) {
            // updateListKey();
          });
        } else {
          log('user1122 same');
          localStorage
              .insertMessage(ChatMessage(
                  id: DateTime.now().millisecondsSinceEpoch,
                  chatRoomId: widget.chatRoomId,
                  content: event.toString(),
                  sender: 'Me',
                  timestamp: DateTime.now()))
              .then((value) {});
        }
        return;
      });
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: 'launch_background',
          ),
        ),
      );
    }
  }
}

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final LocalDatabaseService localDatabaseService = LocalDatabaseService();
  final MessageDatabaseService messageDatabaseService =
      MessageDatabaseService();
  await messageDatabaseService.initDatabase();
  await localDatabaseService.initDatabase();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
  // NotificationService().initNotification();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await initializeService();
  // NotificationService().initNotification();
  // NotificationService().getFCMToken();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0.0,
        ),
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

// Crude counter to make messages unique
int _messageCount = 0;

/// The API endpoint here accepts a raw FCM payload for demonstration purposes.
String constructFCMPayload(String? token) {
  _messageCount++;
  log('Constructing FCM payload: $token');
  return jsonEncode({
    'token': token,
    'data': {
      'via': 'FlutterFire Cloud Messaging!!!',
      'count': _messageCount.toString(),
    },
    'notification': {
      'title': 'Hello FlutterFire!',
      'body': 'This notification (#$_messageCount) was created via FCM!',
    },
  });
}
