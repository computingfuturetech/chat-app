// To parse this JSON data, do
//
//     final chatroom = chatroomFromJson(jsonString);

import 'dart:convert';

List<Chatroom> chatroomFromJson(String str) =>
    List<Chatroom>.from(json.decode(str).map((x) => Chatroom.fromJson(x)));

String chatroomToJson(List<Chatroom> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chatroom {
  final String chatRoomId;
  final String chatType;
  final int memberCount; // Ensure memberCount is of type int
  final List<MembersInfo>? membersInfo;
  final LastMessage? lastMessage;

  Chatroom({
    required this.chatRoomId,
    required this.chatType,
    required this.memberCount,
    this.membersInfo,
    this.lastMessage,
  });

  factory Chatroom.fromJson(Map<String, dynamic> json) => Chatroom(
        chatRoomId: json["chat_room_id"],
        chatType: json["chat_type"],
        memberCount: json["member_count"],
        membersInfo: json["members_info"] == null
            ? []
            : List<MembersInfo>.from(
                json["members_info"].map((x) => MembersInfo.fromJson(x))),
        lastMessage: json["last_message"] == null
            ? null
            : LastMessage.fromJson(json["last_message"]),
      );

  Map<String, dynamic> toJson() => {
        "chat_room_id": chatRoomId,
        "chat_type": chatType,
        "member_count": memberCount,
        "members_info": membersInfo == null
            ? []
            : List<dynamic>.from(membersInfo!.map((x) => x.toJson())),
        "last_message": lastMessage?.toJson(),
      };
}

class LastMessage {
  final String message;
  final int userId;
  final String timestamp;

  LastMessage({
    required this.message,
    required this.userId,
    required this.timestamp,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) => LastMessage(
        message: json["message"],
        userId: json["user_id"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "user_id": userId,
        "timestamp": timestamp,
      };
}

class MembersInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String bio;
  final dynamic image;

  MembersInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    this.image,
  });

  factory MembersInfo.fromJson(Map<String, dynamic> json) => MembersInfo(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        bio: json["bio"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "bio": bio,
        "image": image,
      };
}
