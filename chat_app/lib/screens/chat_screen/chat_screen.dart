import 'dart:developer';

import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/bottom_sheet_modal.dart';
import 'package:flutter/cupertino.dart';
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
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://192.168.0.189:8000/ws/chat/19.13/'),
  );
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
              //   child: ListView.builder(
              //     padding: const EdgeInsets.symmetric(horizontal: 8),
              //     physics: const BouncingScrollPhysics(),
              //     itemCount: 20,
              //     itemBuilder: (context, index) {
              //       return Column(
              //         children: [
              //           Container(
              //             margin: const EdgeInsets.only(top: 10),
              //             child: Column(
              //               crossAxisAlignment: index % 2 == 0
              //                   ? CrossAxisAlignment.end
              //                   : CrossAxisAlignment.start,
              //               children: [
              //                 Row(
              //                   mainAxisAlignment: index % 2 == 0
              //                       ? MainAxisAlignment.end
              //                       : MainAxisAlignment.start,
              //                   children: [
              //                     Container(
              //                       padding: const EdgeInsets.symmetric(
              //                           horizontal: 15, vertical: 8),
              //                       decoration: BoxDecoration(
              //                         color: index % 2 == 0
              //                             ? primartColor
              //                             : chatCardColor,
              //                         borderRadius: index % 2 == 0
              //                             ? const BorderRadius.only(
              //                                 topLeft: Radius.circular(10),
              //                                 bottomLeft: Radius.circular(10),
              //                                 bottomRight: Radius.circular(10),
              //                               )
              //                             : const BorderRadius.only(
              //                                 topRight: Radius.circular(10),
              //                                 bottomLeft: Radius.circular(10),
              //                                 bottomRight: Radius.circular(10),
              //                               ),
              //                       ),
              //                       child: Text(
              //                         'Hello',
              //                         style: TextStyle(
              //                           color: index % 2 == 0
              //                               ? whiteColor
              //                               : primaryFontColor,
              //                           fontSize: 12,
              //                           fontFamily: circularStdBook,
              //                         ),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //                 const SizedBox(height: 5),
              //                 const Text(
              //                   '12:00 PM',
              //                   textAlign: TextAlign.end,
              //                   style: TextStyle(
              //                     color: greyColor,
              //                     fontSize: 10,
              //                     fontFamily: circularStdBook,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           Container(
              //             padding: const EdgeInsets.symmetric(
              //                 horizontal: 10, vertical: 5),
              //             decoration: BoxDecoration(
              //               color: lightgreyColor,
              //               borderRadius: BorderRadius.circular(6),
              //             ),
              //             child: const Text(
              //               'Today',
              //               textAlign: TextAlign.end,
              //               style: TextStyle(
              //                 color: primaryFontColor,
              //                 fontSize: 10,
              //                 fontFamily: carosMedium,
              //               ),
              //             ),
              //           ),
              //         ],
              //       );
              //     },
              //   ),
              // ),
              child: StreamBuilder(
                stream: _channel.stream,
                builder: (context, snapshot) {
                  log('snapshot: ${snapshot.data}');
                  return Text(snapshot.hasData ? '${snapshot.data}' : '');
                },
              ),
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
                                log('inside send if');
                                _channel.sink.add(_controller.text);
                              }
                              // chatController.sendMessage();
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
                                      context, ImageSource.camera);
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
