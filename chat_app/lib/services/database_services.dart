import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:chat_app/models/chat_room/chat_room.dart';

class LocalDatabaseService {
  late Database _database;
  bool _isInitialized = false; // Track initialization state

  // Initialize the database
  Future<void> initDatabase() async {
    try {
      log('Initializing database...');
      final path = join(await getDatabasesPath(), 'chat_app_database.db');
      log('Database path: $path');
      _database = await openDatabase(
        path,
        onCreate: (db, version) {
          // Create tables if they don't exist
          log('Creating database tables...');
          db.execute(
            'CREATE TABLE chat_rooms(chat_room_id TEXT PRIMARY KEY, chat_type TEXT, member_count INTEGER, members_info TEXT, last_message TEXT)',
          );
        },
        version: 1,
      );
      _isInitialized = true; // Mark as initialized
      log('Database initialized successfully!');
    } catch (e) {
      log('Error initializing database: $e');
      rethrow; // Rethrow the error to indicate initialization failure
    }
  }

  // Ensure the database is initialized before performing any operations
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initDatabase(); // Initialize if not already done
    }
  }

  // Fetch chat room data from the local database
  Stream<List<Chatroom>> fetchChatRoomsData() async* {
    try {
      log('Fetching chat rooms data...');
      final rows = await _database.query('chat_rooms');
      log('Chat rooms data: $rows');

      final chatRooms = rows.map((row) {
        // Parse the JSON string into a LastMessage object
        final LastMessage lastMessage = LastMessage.fromJson(
          json.decode(row['last_message'] as String),
        );

        // Create the Chatroom object
        return Chatroom(
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
      rethrow; // Rethrow the error for better error handling
    }
  }

// Helper function to parse the members info
  List<MembersInfo> parseMembersInfo(String membersInfoJson) {
    final List<Map<String, dynamic>> membersInfoMapList =
        List<Map<String, dynamic>>.from(json.decode(membersInfoJson) as List);
    return membersInfoMapList
        .map((member) => MembersInfo.fromJson(member))
        .toList();
  }

  // Save chat room data to the local database
  Future<void> saveChatRoomData(Chatroom chatRoom) async {
    await ensureInitialized(); // Ensure database is initialized
    await _database.insert(
      'chat_rooms',
      chatRoom.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateChatRooms(List<Chatroom> chatRooms) async {
    try {
      await ensureInitialized(); // Ensure database is initialized

      log('Updating chat rooms...');
      await _database.transaction((txn) async {
        log('Updating chat rooms in transaction...');
        for (final chatRoom in chatRooms) {
          log('Updating chat room ${chatRoom.chatRoomId}');

          // Convert membersInfo and lastMessage to JSON strings
          final Map<String, dynamic> jsonData = {
            'chat_room_id': chatRoom.chatRoomId,
            'chat_type': chatRoom.chatType,
            'member_count': chatRoom.memberCount,
            'members_info': json.encode(chatRoom.membersInfo),
            'last_message': json.encode(chatRoom.lastMessage),
          };

          log('\n\n Chatroom Data under db: $jsonData');

          // Perform database update
          final rowsAffected = await txn.update(
            'chat_rooms',
            jsonData,
            where: 'chat_room_id = ?',
            whereArgs: [chatRoom.chatRoomId],
          );

          if (rowsAffected == 0) {
            // If no rows were affected, insert the data instead
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
