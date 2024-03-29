import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chat_app/models/chat_model/chat_model.dart';
import 'package:chat_app/services/chat_message_database_service.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/bottom_sheet_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final image, username;
  const ChatScreen({super.key, this.image, this.username});

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

  @override
  void initState() {
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://59e2-182-185-217-227.ngrok-free.app/ws/chat/1/3/'),
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
      userId = data['user_id'];
      log('value: $data');
      // log('event: ${event.jsonEncode(event)}');
      // log('event: ${event['message']}');
      if (data['message'] == null && data['image'] != null) {
        _localDatabaseService
            .insertMessage(ChatMessage(
                content: event.toString(),
                sender: 'Other',
                timestamp: DateTime.now()))
            .then(
              (value) => setState(
                () {
                  // log('value:dsafas');
                },
              ),
            );
        return;
      }
      setState(() {});
      _localDatabaseService
          .insertMessage(ChatMessage(
              // content: data['message'].toString(),
              content: event.toString(),
              sender: 'Other',
              timestamp: DateTime.now()))
          .then(
            (value) => setState(
              () {
                // log('value:dsafas');
              },
            ),
          );
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
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final message;
                        final timestamp;
                        final String sender;
                        final image;
                        final decodedData;
                        data[index].content.contains("\"username\"")
                            ? decodedData = json.decode(data[index].content)
                            : decodedData = data[index].content;
                        data[index].content.contains("\"timestamp\"")
                            ? timestamp = decodedData['timestamp']
                            : timestamp = data[index].timestamp;
                        data[index].content.contains("\"message\"")
                            ? message = decodedData['message']
                            : message = data[index].content;
                        sender = data[index].sender;
                        data[index].content.contains("\"image\"")
                            ? image = decodedData['image']
                            : image = data[index].content;
                        if (message == null && image != null) {
                          log('image: $decodedData');
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      userId == authController.userid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          userId == authController.userid
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                userId == authController.userid
                                                    ? primartColor
                                                    : chatCardColor,
                                            borderRadius:
                                                userId == authController.userid
                                                    ? const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      )
                                                    : const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
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
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      // snapshot.data['timestamp'],
                                      // sender,
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
                          // return Container();
                        } else {
                          return Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      userId == authController.userid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          userId == authController.userid
                                              ? MainAxisAlignment.end
                                              : MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                userId == authController.userid
                                                    ? primartColor
                                                    : chatCardColor,
                                            borderRadius:
                                                userId == authController.userid
                                                    ? const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      )
                                                    : const BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(10),
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(10),
                                                      ),
                                          ),
                                          child: Text(
                                            message,
                                            // 'has',
                                            style: TextStyle(
                                              color: userId ==
                                                      authController.userid
                                                  ? whiteColor
                                                  : primaryFontColor,
                                              fontSize: 12,
                                              fontFamily: circularStdBook,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      // snapshot.data['timestamp'],
                                      // sender,
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
                              // Container(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 10, vertical: 5),
                              //   decoration: BoxDecoration(
                              //     color: lightgreyColor,
                              //     borderRadius: BorderRadius.circular(6),
                              //   ),
                              //   child: const Text(
                              //     'Today',
                              //     textAlign: TextAlign.end,
                              //     style: TextStyle(
                              //       color: primaryFontColor,
                              //       fontSize: 10,
                              //       fontFamily: carosMedium,
                              //     ),
                              //   ),
                              // ),
                            ],
                          );
                        }
                      },
                    );
                  }),
            ),
            //   child: StreamBuilder(
            //     stream: _localDatabaseService.getMessages(),
            //     builder: (context, snapshot) {
            //       if (snapshot.hasData) {
            //         log('snapshot: ${snapshot.data}');
            //         // Parse received JSON data
            //         var data = snapshot.data!;
            //         // Check if it's a message
            //         return ListView.builder(
            //             itemCount: data.length,
            //             itemBuilder: (context, index) {
            //               final message;
            //               final timestamp;
            //               final String sender;
            //               final decodedData;
            //               data[index].content.contains("\"username\"")
            //                   ? decodedData = json.decode(data[index].content)
            //                   : decodedData = data[index].content;
            //               data[index].content.contains("\"timestamp\"")
            //                   ? timestamp = decodedData['timestamp']
            //                   : timestamp = data[index].timestamp;
            //               data[index].content.contains("\"message\"")
            //                   ? message = decodedData['message']
            //                   : message = data[index].content;
            //               data[index].content.contains("\"sender\"")
            //                   ? sender = 'Other'
            //                   : sender = 'Me';
            //               log('sadhjsad: ${data[index].sender}');

            //               return ListTile(
            //                 title: Text(message.toString()),
            //                 subtitle: Text(data[index].sender.toString()),
            //               );
            //             });
            //       }
            //       // Return an empty container if no data or not a message
            //       return Container();
            //     },
            //   ),
            // ),
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
                                //     content: _controller.text,
                                //     sender: 'Me',
                                //     timestamp: DateTime.now()));
                                setState(() {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });

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
}
