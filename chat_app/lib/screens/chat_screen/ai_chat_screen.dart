// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';
import 'package:chat_app/utils/exports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

/// Message route arguments.
class MessageArguments {
  /// The RemoteMessage
  final RemoteMessage message;

  /// Whether this message caused the application to open.
  final bool openedApplication;

  // ignore: public_member_api_docs
  MessageArguments(this.message, this.openedApplication);
}

class AIChatScreen extends StatefulWidget {
  final username, chatRoomId, secondUserId;
  const AIChatScreen(
      {super.key, this.username, required this.chatRoomId, this.secondUserId});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _localDatabaseService = MessageDatabaseService();
  bool isDbOpen = false;
  final ScrollController _scrollController = ScrollController();
  final authController = Get.find<AuthController>();
  var userId;
  late final WebSocketChannel _channel;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String? initialMessage;

  @override
  void initState() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
          '$webSocketUrl/ws/chat/${widget.chatRoomId}/${authController.userid}/'),
    );
    _localDatabaseService.initDatabase().then((value) => !isDbOpen
        ? setState(() {
            isDbOpen = true;
          })
        : null);

    super.initState();

    _channel.stream.listen((event) async {
      log('event: $event');
      var data = json.decode(event);
      userId = data['user_id'];
      if (userId.toString() != authController.userid.toString()) {
        _localDatabaseService
            .insertMessage(ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch,
                chatRoomId: widget.chatRoomId,
                content: event.toString(),
                sender: 'Other',
                timestamp: DateTime.now()))
            .then((value) {
          setState(
            () {
              scrollToBottom();
            },
          );
        });
      } else {
        _localDatabaseService
            .insertMessage(ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch,
                chatRoomId: widget.chatRoomId,
                content: event.toString(),
                sender: 'Me',
                timestamp: DateTime.now()))
            .then((value) {
          scrollToBottom();
          setState(
            () {},
          );
        });
      }
      return;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());
    return Scaffold(
      backgroundColor: primartColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: primartColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          child: AppBar(
            leading: InkWell(
              splashColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                Get.back();
              },
              child: const Icon(
                size: 20,
                CupertinoIcons.back,
                color: whiteColor,
              ),
            ),
            leadingWidth: 30,
            title: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: primaryFontColor,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: CachedNetworkImage(
                              placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                              errorWidget: (context, url, error) => const Icon(
                                    Icons.person,
                                    color: whiteColor,
                                  ),
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                              imageUrl: 'https://picsum.photos/250?image=9'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 12,
                            width: 12,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Center(
                              child: Container(
                                height: 8,
                                width: 8,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 14,
                        fontFamily: carosMedium,
                      ),
                    ),
                    const Text(
                      'Active Now',
                      style: TextStyle(
                        color: lightgreyColor,
                        fontSize: 12,
                        fontFamily: circularStdBook,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  CupertinoIcons.ellipsis_vertical,
                  color: whiteColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                  stream: _localDatabaseService.getMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    log('snapshot: ${snapshot.data}');
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No Messages found'),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching data'),
                      );
                    }
                    var data = snapshot.data!;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollToBottom();
                    });
                    return ListView.builder(
                      key: _listKey,
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final message;
                        final timestam;
                        final sender = data[index].sender;
                        log('sender1: $sender');
                        final image;
                        final decodedData;
                        data[index].content.contains("username")
                            ? decodedData = json.decode(data[index].content)
                            : decodedData = data[index].content;
                        log('decodedData: $decodedData');
                        userId = decodedData['user_id'];
                        log('UserId: $userId and authController.userid: ${authController.userid}');
                        data[index].content.contains("timestamp")
                            ? timestam = decodedData['timestamp']
                            : timestam = data[index].timestamp;
                        List<String> parts = timestam.split(':');
                        int hour = int.parse(parts[0]);
                        int minute = int.parse(parts[1]);

                        // Format the time
                        final timestamp = DateFormat('hh:mm a')
                            .format(DateTime(0, 1, 1, hour, minute));

                        data[index].content.contains("content")
                            ? message = decodedData['content']
                            : message = data[index].content;
                        data[index].content.contains("message_type")
                            ? image = decodedData['message_type']
                            : image = data[index].content;

                        log('simage1122: ${image.toString()}');

                        return Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: sender == 'Me'
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: sender == 'Me'
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: sender == 'Me'
                                            ? primartColor
                                            : chatCardColor,
                                        borderRadius: sender == 'Me'
                                            ? const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomLeft: Radius.circular(10))
                                            : const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                      ),
                                      child: Text(
                                        message,
                                        style: TextStyle(
                                          color: sender == 'Me'
                                              ? whiteColor
                                              : primaryFontColor,
                                          fontSize: 12,
                                          fontFamily: circularStdBook,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    timestamp.toString(),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                      color: greyColor,
                                      fontSize: 10,
                                      fontFamily: circularStdBook,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }),
            ),
            Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteColor,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      onFieldSubmitted: (value) {
                        chatController.isWriting.value = false;
                        log('value: ${chatController.isWriting.value}');
                      },
                      controller: _controller,
                      cursorColor: secondaryFontColor,
                      onChanged: (value) =>
                          chatController.isWriting.value = true,
                      decoration: InputDecoration(
                        fillColor: lightgreyColor,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        filled: true,
                        hintText: 'Write your message',
                        hintStyle: const TextStyle(
                          color: greyColor,
                          fontSize: 14,
                          fontFamily: circularStdBook,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      log('inside send');
                      if (_controller.text.isNotEmpty) {
                        log('inside send if');
                        _channel.sink.add(
                          jsonEncode({
                            'type': 'ai_type',
                            'username': widget.username,
                            'message': _controller.text,
                            'toID': widget.secondUserId,
                          }),
                        );
                        // sendPushMessage();
                        log('message sent');
                        scrollToBottom();

                        _controller.clear();
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.only(
                          left: 12, right: 8, top: 10, bottom: 10),
                      decoration: BoxDecoration(
                        color: primartColor,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: const Icon(
                        size: 20,
                        Icons.send,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}
