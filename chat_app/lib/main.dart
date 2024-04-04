import 'dart:developer';

import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/services/chat_message_database_service.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/notification_services.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter/services.dart';

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

  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
