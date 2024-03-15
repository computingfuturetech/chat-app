// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

List<User> userFromJson(String str) =>
    List<User>.from(json.decode(str).map((x) => User.fromJson(x)));

String userToJson(List<User> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class User {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? image;

  User({
    this.id,
    this.firstName,
    this.lastName,
    this.bio,
    this.image,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? bio,
    String? image,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        bio: bio ?? this.bio,
        image: image ?? this.image,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
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
