// To parse this JSON data, do
//
//     final chatroom = chatroomFromJson(jsonString);

import 'dart:convert';

List<Chatroom> chatroomFromJson(String str) =>
    List<Chatroom>.from(json.decode(str).map((x) => Chatroom.fromJson(x)));

String chatroomToJson(List<Chatroom> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chatroom {
  final String? chatRoomId;
  final String? chatType;
  final int? memberCount;
  final List<MembersInfo>? membersInfo;
  final LastMessage? lastMessage;

  Chatroom({
    this.chatRoomId,
    this.chatType,
    this.memberCount,
    this.membersInfo,
    this.lastMessage,
  });

  Chatroom copyWith({
    String? chatRoomId,
    String? chatType,
    int? memberCount,
    List<MembersInfo>? membersInfo,
    LastMessage? lastMessage,
  }) =>
      Chatroom(
        chatRoomId: chatRoomId ?? this.chatRoomId,
        chatType: chatType ?? this.chatType,
        memberCount: memberCount ?? this.memberCount,
        membersInfo: membersInfo ?? this.membersInfo,
        lastMessage: lastMessage ?? this.lastMessage,
      );

  factory Chatroom.fromJson(Map<String, dynamic> json) => Chatroom(
        chatRoomId: json["chat_room_id"],
        chatType: json["chat_type"],
        memberCount: json["member_count"],
        membersInfo: json["members_info"] == null
            ? []
            : List<MembersInfo>.from(
                json["members_info"]!.map((x) => MembersInfo.fromJson(x))),
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
  final String? message;
  final int? userId;
  final String? timestamp;

  LastMessage({
    this.message,
    this.userId,
    this.timestamp,
  });

  LastMessage copyWith({
    String? message,
    int? userId,
    String? timestamp,
  }) =>
      LastMessage(
        message: message ?? this.message,
        userId: userId ?? this.userId,
        timestamp: timestamp ?? this.timestamp,
      );

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
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final dynamic image;

  MembersInfo({
    this.id,
    this.firstName,
    this.lastName,
    this.bio,
    this.image,
  });

  MembersInfo copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? bio,
    dynamic image,
  }) =>
      MembersInfo(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        bio: bio ?? this.bio,
        image: image ?? this.image,
      );

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
