import 'dart:developer';

import 'package:chat_app/models/chat_model/chat_model.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class MessageDatabaseService {
  late final Database _database;

  Future<void> initDatabase() async {
    log('Initializing database...');
    // final path = await getDatabasesPath();
    final path = join(await getDatabasesPath(), 'chat_database.db');
    log('Database path: $path');

    _database = await openDatabase(
      // join(path, 'chat_database.db'),
      path,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE messages(id INTEGER PRIMARY KEY, content TEXT, sender TEXT, timestamp TEXT)',
        );
      },
      version: 1,
    );
    log('Message Database initialized successfully!');
  }

  Future<void> insertMessage(ChatMessage message) async {
    initDatabase();
    await _database.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Stream<List<ChatMessage>> getMessages() {
    initDatabase();
    final streamController = StreamController<List<ChatMessage>>();
    streamController.sink.addStream(_database
        .query('messages')
        .then(
            (messages) => messages.map((m) => ChatMessage.fromMap(m)).toList())
        .asStream());
    return streamController.stream;
  }
}
