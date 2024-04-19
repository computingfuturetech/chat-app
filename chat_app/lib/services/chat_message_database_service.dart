import 'dart:developer';

import 'package:chat_app/utils/exports.dart';

class MessageDatabaseService {
  // final _messageController = Get.find<ChatController>();
  late final Database _database;
  bool _isDatabaseInitialized = false;

  Future<void> initDatabase() async {
    if (_isDatabaseInitialized) {
      return;
    } else {
      final path = join(await getDatabasesPath(), 'chat_database.db');

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
    }
  }

  Future<void> insertMessage(ChatMessage message) async {
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
