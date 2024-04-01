// To parse this JSON data, do
//
//     final chatroom = chatroomFromJson(jsonString);

import 'dart:convert';

List<Chatroom> chatroomFromJson(String str) =>
    List<Chatroom>.from(json.decode(str).map((x) => Chatroom.fromJson(x)));

String chatroomToJson(List<Chatroom> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Chatroom {
  int id;
  String chatRoomId;
  String chatType;
  int memberCount;
  List<MembersInfo> membersInfo;
  LastMessage lastMessage;

  Chatroom({
    required this.id,
    required this.chatRoomId,
    required this.chatType,
    required this.memberCount,
    required this.membersInfo,
    required this.lastMessage,
  });

  Chatroom copyWith({
    int? id,
    String? chatRoomId,
    String? chatType,
    int? memberCount,
    List<MembersInfo>? membersInfo,
    LastMessage? lastMessage,
  }) =>
      Chatroom(
        id: id ?? this.id,
        chatRoomId: chatRoomId ?? this.chatRoomId,
        chatType: chatType ?? this.chatType,
        memberCount: memberCount ?? this.memberCount,
        membersInfo: membersInfo ?? this.membersInfo,
        lastMessage: lastMessage ?? this.lastMessage,
      );

  factory Chatroom.fromJson(Map<String, dynamic> json) => Chatroom(
        id: json["id"],
        chatRoomId: json["chat_room_id"],
        chatType: json["chat_type"],
        memberCount: json["member_count"],
        membersInfo: List<MembersInfo>.from(
            json["members_info"].map((x) => MembersInfo.fromJson(x))),
        lastMessage: LastMessage.fromJson(json["last_message"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "chat_room_id": chatRoomId,
        "chat_type": chatType,
        "member_count": memberCount,
        "members_info": List<dynamic>.from(membersInfo.map((x) => x.toJson())),
        "last_message": lastMessage.toJson(),
      };
}

class LastMessage {
  String message;
  dynamic userId;
  String timestamp;

  LastMessage({
    required this.message,
    required this.userId,
    required this.timestamp,
  });

  LastMessage copyWith({
    String? message,
    dynamic userId,
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
  int id;
  String firstName;
  String lastName;
  String bio;
  String image;

  MembersInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.image,
  });

  MembersInfo copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? bio,
    String? image,
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
