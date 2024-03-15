import 'dart:convert';

List<FriendRequest> friendRequestFromJson(String str) =>
    List<FriendRequest>.from(json
        .decode(str)["friend_requests"]
        .map((x) => FriendRequest.fromJson(x)));

class FriendRequest {
  FriendRequest({
    required this.fromUserId,
    required this.firstName,
    required this.lastName,
    required this.bio,
    this.imageUrl,
    required this.createdAt,
  });

  int fromUserId;
  String firstName;
  String lastName;
  String bio;
  dynamic imageUrl;
  DateTime createdAt;

  factory FriendRequest.fromJson(Map<String, dynamic> json) => FriendRequest(
        fromUserId: json["from_user_id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        bio: json["bio"],
        imageUrl: json["image_url"],
        createdAt: DateTime.parse(json["created_at"]),
      );

}
