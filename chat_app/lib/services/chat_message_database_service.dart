import 'dart:developer';

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
            'CREATE TABLE messages(id INTEGER PRIMARY KEY, sender TEXT, content TEXT, timestamp INTEGER, chatRoomId TEXT)',
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
    log('Inserting message: ${message.content}');
    try {
      await _database
          .insert(
            'messages',
            message.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          )
          .then((value) => log('Message inserted'));
      // _updateMessagesStream();
    } catch (e) {
      log('Error inserting message: $e');
    }
  }
  //   void _updateMessagesStream() async {
  //   final result = await _database.query('messages');
  //   if (result.isNotEmpty) {
  //     _messagesController
  //         .add(result.map((json) => ChatMessage.fromMap(json)).toList());
  //   }
  // }

  // Stream<List<ChatMessage>> getMessages() async* {
  //   await initDatabase();
  //   yield* _database
  //       .query('messages')
  //       .then(
  //           (messages) => messages.map((m) => ChatMessage.fromMap(m)).toList())
  //       .asStream();
  // }

  Stream<List<ChatMessage>> getMessages(String chatRoomId) async* {
    await initDatabase();
    final result = await _database.query(
      'messages',
      where: 'chatRoomId = ?',
      whereArgs: [chatRoomId],
    );

    if (result.isNotEmpty) {
      yield result.map((json) => ChatMessage.fromMap(json)).toList();
    }
  }
}
