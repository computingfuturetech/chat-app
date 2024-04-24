
class ChatMessage {
  final int id; // Add this line
  final String content;
  final String sender;
  final DateTime timestamp;
  final String chatRoomId;

  ChatMessage({
    required this.id, // Add this line
    required this.content,
    required this.sender,
    required this.timestamp,
    required this.chatRoomId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Add this line
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
      'chatRoomId': chatRoomId,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'], // Add this line
      content: map['content'],
      sender: map['sender'],
      timestamp: DateTime.parse(map['timestamp']),
      chatRoomId: map['chatRoomId'],
    );
  }
}
