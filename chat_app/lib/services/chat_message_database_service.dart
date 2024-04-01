import 'dart:async';
import 'dart:developer';

import 'package:chat_app/models/chat_model/chat_model.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MessageDatabaseService {
  // final _messageController = Get.find<ChatController>();
  late final Database _database;
  bool _isDatabaseInitialized = false;

  Future<void> initDatabase() async {
    log('dbdb isDatabaseInitialized: $_isDatabaseInitialized');
    // if (_messageController.isDatabaseInitialized.value) {
    if (_isDatabaseInitialized) {
      log('Database already initialized!');
      return;
    } else {
      log('Initializing database...');

      final path = join(await getDatabasesPath(), 'chat_database.db');
      log('Database path: $path');

      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE messages(id INTEGER PRIMARY KEY, content TEXT, sender TEXT, timestamp TEXT)',
          );
        },
        version: 1,
      );

      // _messageController.isDatabaseInitialized.value = true;
      _isDatabaseInitialized = true;
      log('Message Database initialized successfully!');
    }
  }

  Future<void> insertMessage(ChatMessage message) async {
    log('message1: ${message.sender}');
    await initDatabase();
    await _database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Stream<List<ChatMessage>> getMessages() async* {
    await initDatabase();
    yield* _database
        .query('messages')
        .then(
            (messages) => messages.map((m) => ChatMessage.fromMap(m)).toList())
        .asStream();
  }
}
