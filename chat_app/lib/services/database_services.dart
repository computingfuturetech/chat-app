import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  late Database _database;
  bool _isInitialized = false;

  Future<void> initDatabase() async {
    try {
      log('Initializing database...');
      final path = join(await getDatabasesPath(), 'chat_app_database.db');
      log('Database path: $path');
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          log('Creating database tables...');
          db.execute(
            'CREATE TABLE chat_rooms(id INTEGER PRIMARY KEY, chat_room_id TEXT , chat_type TEXT, member_count INTEGER, members_info TEXT, last_message TEXT)',
          );
        },
        version: 1,
      );
      _isInitialized = true;
      log('Database initialized successfully!');
    } catch (e) {
      log('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initDatabase();
    }
  }

  Stream<List<Chatroom>> fetchChatRoomsData() async* {
    try {
      log('Fetching chat rooms data...');
      final rows = await _database.query('chat_rooms');
      log('Chat rooms data: $rows');

      final chatRooms = rows.map((row) {
        final lastMessage =
            LastMessage.fromJson(json.decode(row['last_message'] as String));

        return Chatroom(
          id: row['id'] as int,
          chatRoomId: row['chat_room_id'] as String,
          chatType: row['chat_type'] as String,
          memberCount: row['member_count'] as int,
          membersInfo: parseMembersInfo(row['members_info'] as String),
          lastMessage: lastMessage,
        );
      }).toList();

      log('Chat rooms: $chatRooms');
      yield chatRooms;
    } catch (e) {
      log('Error fetching chat rooms data: $e');
      rethrow;
    }
  }

  List<MembersInfo> parseMembersInfo(String membersInfoJson) {
    final List<Map<String, dynamic>> membersInfoMapList =
        List<Map<String, dynamic>>.from(json.decode(membersInfoJson) as List);
    return membersInfoMapList
        .map((member) => MembersInfo.fromJson(member))
        .toList();
  }

  Future<void> saveChatRoomData(Chatroom chatRoom) async {
    await ensureInitialized();
    await _database.insert(
      'chat_rooms',
      chatRoom.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateChatRooms(List<Chatroom> chatRooms) async {
    log('Updating chat rooms...');
    try {
      await ensureInitialized();

      log('Updating chat rooms...');
      await _database.transaction((txn) async {
        log('Updating chat rooms in transaction...');
        for (final chatRoom in chatRooms) {
          log('Updating chat room ${chatRoom.chatRoomId}');

          final Map<String, dynamic> jsonData = {
            "id": chatRoom.id,
            'chat_room_id': chatRoom.chatRoomId,
            'chat_type': chatRoom.chatType,
            'member_count': chatRoom.memberCount,
            'members_info': json.encode(chatRoom.membersInfo),
            'last_message': json.encode(chatRoom.lastMessage),
          };

          log('\n\n Chatroom Data under db: $jsonData');

          final rowsAffected = await txn.update(
            'chat_rooms',
            jsonData,
            where: 'chat_room_id = ?',
            whereArgs: [chatRoom.chatRoomId],
          );

          if (rowsAffected == 0) {
            log('Chat room ${chatRoom.chatRoomId} not found, inserting instead...');
            await txn.insert(
              'chat_rooms',
              jsonData,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          log('Updated $rowsAffected rows for chat room ${chatRoom.chatRoomId}');
        }
        log('Committing transaction...');
        txn.query('chat_rooms').then((rows) {
          log('Chat rooms after update: $rows');
        });
      });
      log('Chat rooms updated successfully');
    } catch (e) {
      log('Error updating chat rooms: $e');
      throw 'Error updating chat rooms: $e';
    }
  }
}
