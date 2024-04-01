import 'dart:convert';
import 'dart:developer';

import 'package:chat_app/models/chat_model/chat_model.dart';
import 'package:chat_app/services/chat_message_database_service.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/bottom_sheet_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final image, username, chatRoomId, secondUserId;
  const ChatScreen(
      {super.key,
      this.image,
      this.username,
      required this.chatRoomId,
      this.secondUserId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _localDatabaseService = MessageDatabaseService();
  bool isDbOpen = false;
  final ScrollController _scrollController = ScrollController();
  final authController = Get.find<AuthController>();
  var userId;
  late final WebSocketChannel _channel;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://2121-182-185-212-155.ngrok-free.app/ws/chat/${widget.chatRoomId}/${authController.userid}/'),
    );
    _localDatabaseService.initDatabase().then((value) => !isDbOpen
        ? setState(() {
            isDbOpen = true;
          })
        : null);

    super.initState();

    // _channel = WebSocketChannel.connect(
    //   Uri.parse('ws://59e2-182-185-217-227.ngrok-free.app/ws/chat/1/3/'),
    // );

    _channel.stream.listen((event) {
      var data = json.decode(event);
      log('data1122: $data');
      userId = data['user_id'];
      log('sender1: $userId');
      // log('userid1: $userId');
      // log('event: ${event.jsonEncode(event)}');
      // log('event: ${event['message']}');
      if (data['message_type'] == 'text_type') {
        if (userId.toString() != authController.userid.toString()) {
          log('user1122: $userId authController.userid: ${authController.userid}');
          log('user1122 not same');
          _localDatabaseService
              .insertMessage(ChatMessage(
                  content: event.toString(),
                  sender: 'Other',
                  timestamp: DateTime.now()))
              .then((value) {
            // updateListKey();
            scrollToBottom();
            setState(
              () {
                log('userid1:sd $ChatMessage');
                // log('value:dsafas');
              },
            );
          });
        } else {
          log('user1122 same');

          // log('userid12: $userId authController.userid: ${authController.userid}');
          _localDatabaseService
              .insertMessage(ChatMessage(
                  content: event.toString(),
                  sender: 'Me',
                  timestamp: DateTime.now()))
              .then((value) {
            // updateListKey();
            scrollToBottom();
            setState(
              () {
                log('userid1:sd $ChatMessage');
                // log('value:dsafas');
              },
            );
          });
        }
        return;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _channel.sink.close();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());
    return GestureDetector(
      onHorizontalDragStart: (details) {
        if (details.localPosition.dx < 100) {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            splashColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              Get.back();
            },
            child: const Icon(
              size: 20,
              CupertinoIcons.back,
              color: primaryFontColor,
            ),
          ),
          leadingWidth: 30,
          title: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: whiteColor,
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
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person),
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            imageUrl: widget.image),
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
                      color: primaryFontColor,
                      fontSize: 14,
                      fontFamily: carosMedium,
                    ),
                  ),
                  const Text(
                    'Active Now',
                    style: TextStyle(
                      color: greyColor,
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
              // icon: Image.asset('assets/icons/Call.png'),
              icon: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: primaryFontColor,
                size: 20,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: _localDatabaseService.getMessages(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CupertinoActivityIndicator(),
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
                        final timestamp;
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
                            ? timestamp = decodedData['timestamp']
                            : timestamp = data[index].timestamp;
                        data[index].content.contains("content")
                            ? message = decodedData['content']
                            : message = data[index].content;
                        data[index].content.contains("image")
                            ? image = decodedData['image']
                            : image = data[index].content;

                        // Check if the message is an image
                        if (message == null && image != null) {
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl: image,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child:
                                                  CupertinoActivityIndicator(),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                            height: 150,
                                            width: 150,
                                            fit: BoxFit.cover,
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
                        } else {
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
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                        }
                      },
                    );
                  }),
            ),
            Container(
              height: 60,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: whiteColor,
                // borderRadius: BorderRadius.circular(1000),
              ),
              child: Row(
                children: [
                  // const SizedBox(width: 20),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return bottomModalSheet(chatController, context);
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: lightgreyColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.attach_file,
                        color: primaryFontColor,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      onTap: () {
                        chatController.isWriting.value = true;
                        log('value: ${chatController.isWriting.value}');
                      },
                      onFieldSubmitted: (value) {
                        chatController.isWriting.value = false;
                        log('value: ${chatController.isWriting.value}');
                      },
                      // controller: chatController.messageController,
                      controller: _controller,
                      cursorColor: secondaryFontColor,
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
                  Obx(
                    () => chatController.isWriting.value
                        ? InkWell(
                            onTap: () {
                              log('inside send');
                              if (_controller.text.isNotEmpty) {
                                _channel.sink.add(
                                  jsonEncode({
                                    'type': 'text_type',
                                    'username': widget.username,
                                    'message': _controller.text,
                                  }),
                                );
                                // _localDatabaseService.insertMessage(ChatMessage(
                                //     content: _controller.text.toString(),
                                //     sender: 'Me',
                                //     timestamp: DateTime.now()));
                                // updateListKey();
                                scrollToBottom();

                                _controller.clear();
                                // chatController.sendMessage();
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
                          )
                        : Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  chatController.pickImage(
                                      context, ImageSource.camera, _channel);
                                },
                                child: const Icon(
                                  CupertinoIcons.camera,
                                  color: primaryFontColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              InkWell(
                                onTap: () {},
                                child: const Icon(
                                  CupertinoIcons.mic,
                                  color: primaryFontColor,
                                ),
                              )
                            ],
                          ),
                  ),
                  // const SizedBox(width: 20),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Function to scroll to the bottom
  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Function to update the list key and trigger rebuild
  // void updateListKey() {
  //   setState(() {
  //     _listKey.currentState!.insertItem(0);
  //   });
  // }
}
