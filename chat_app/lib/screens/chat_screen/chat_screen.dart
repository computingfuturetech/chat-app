import 'dart:developer';
import 'dart:io';

import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';

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

  late AudioRecorder audioRecord;
  bool isRecording = false;
  String audioPath = "";

  bool isAudioPlayerInitialized = false; // Add this flag

  @override
  void initState() {
    log('isRecording: $isRecording');
    _channel = WebSocketChannel.connect(
      Uri.parse(
          'ws://4077-119-73-114-193.ngrok-free.app/ws/chat/${widget.chatRoomId}/${authController.userid}/'),
    );
    _localDatabaseService.initDatabase().then((value) => !isDbOpen
        ? setState(() {
            isDbOpen = true;
          })
        : null);

    super.initState();
    _channel.stream.listen((event) {
      var data = json.decode(event);
      log('data1122: $data');
      userId = data['user_id'];
      log('sender1: $userId');
      if (userId.toString() != authController.userid.toString()) {
        log('user1122: $userId authController.userid: ${authController.userid}');
        log('user1122 not same');
        _localDatabaseService
            .insertMessage(ChatMessage(
                id: DateTime.now().millisecondsSinceEpoch,
                chatRoomId: widget.chatRoomId,
                content: event.toString(),
                sender: 'Other',
                timestamp: DateTime.now()))
            .then((value) {
          // updateListKey();
          scrollToBottom();
          setState(
            () {
              log('userid1:sd $ChatMessage');
            },
          );
        });
      } else {
        log('user1122 same');
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
            () {
              log('userid1:sd $ChatMessage');
            },
          );
        });
      }
      return;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    audioRecord.dispose();
    super.dispose();
  }

  bool playing = false;
  Future<void> startRecording() async {
    audioRecord = AudioRecorder();
    // if (!await _checkPermission()) {
    //   log('Recording Permission not granted');
    //   return;
    // }

    try {
      log("START RECORDING+++++++++++++++++++++++++++++++++++++++++++++++++");

      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDocDir.path}/myFile.m4a';
      await audioRecord.start(const RecordConfig(), path: filePath);
      setState(() {
        isRecording = true;
      });
      log('Recording started');
    } catch (e) {
      log('Error starting recording: $e');
    }
  }

  Future<bool> _checkPermission() async {
    var micPermission = await Permission.microphone.request();
    final storagePermission = await Permission.storage.request();

    return micPermission.isGranted && storagePermission.isGranted;
  }

  Future<void> stopRecording() async {
    try {
      log("STOP RECORDING+++++++++++++++++++++++++++++++++++++++++++++++++");
      final path = await audioRecord.stop();
      log('Recording stopped: $path');

      setState(() {
        isRecording = false;
        audioPath = path ?? '';
      });
      if (audioPath.isNotEmpty) {
        await uploadAndDeleteRecording(audioPath);
      }
      await audioRecord.stop();
    } catch (e, stackTrace) {
      log('Error stopping recording: $e\n$stackTrace');
    }
  }

  Future<void> uploadAndDeleteRecording(audiopath) async {
    try {
      log('Sending Recording');

      final file = File(audiopath);
      if (!file.existsSync()) {
        log("UPLOADING FILE NOT EXIST+++++++++++++++++++++++++++++++++++++++++++++++++");
        return;
      }
      log("UPLOADING FILE ++++++++++++++++$audiopath+++++++++++++++++++++++++++++++++");
      final bytes = await file.readAsBytes();
      log('bytes: $bytes');
      _channel.sink.add(
        jsonEncode({
          'type': 'audio_type',
          'username': widget.username,
          'message': bytes,
        }),
      );
    } catch (e) {
      log('Error uploading audio: $e');
    }
  }

  void openDocument(BuildContext context, String message) async {
    try {
      final directory = await getDownloadsDirectory();
      log('directory: $directory');

      final fileExtension =
          message.split('.').last; // Extract file extension from message
      final fileName =
          message.split('/').last; // Extract file name from message

      final filePath = Platform.isAndroid
          ? '/storage/emulated/0/Download/$fileName'
          : '${directory!.path}/$fileName'; // Construct file path with file name
      log('fileExtension: $fileExtension');
      log('filePath: $filePath');

      // Check if the file exists in the temporary directory
      if (await File(filePath).exists()) {
        // File exists, so open it directly
        log('File exists, so opening directly');
        OpenFile.open(filePath).then((value) {
          if (value.message == 'done') {
            Fluttertoast.showToast(
                msg: 'File opened successfully',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: 'No app found to open the file',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          }
        }).catchError((e) {
          Fluttertoast.showToast(
              msg: 'Error opening file: $e',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      } else {
        // File doesn't exist, so download it
        final downloadedFile = await FileDownloader.downloadFile(
          url: "https://4077-119-73-114-193.ngrok-free.app$message",
          name: fileName, // Specify the file name to save as
          downloadDestination: DownloadDestinations.publicDownloads,
          onDownloadCompleted: (String downloadedFilePath) {
            log('File downloaded successfully at $downloadedFilePath');
            Fluttertoast.showToast(
                msg: 'File downloaded successfully at $downloadedFilePath',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          },
          onDownloadError: (String error) {
            Fluttertoast.showToast(
                msg: 'Download error: $error',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          },
        );

        // Open the downloaded file using open_file package
        OpenFile.open(downloadedFile!.path).then((value) {
          if (value.message == 'done') {
            Fluttertoast.showToast(
                msg: 'File opened successfully',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          } else {
            Fluttertoast.showToast(
                msg: 'No app found to open the file',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          }
        }).catchError((e) {
          Fluttertoast.showToast(
              msg: 'Error opening file: $e',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Error opening document: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Get.put(ChatController());
    return Scaffold(
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
                stream: _localDatabaseService.getMessages(widget.chatRoomId),
                builder: (context, snapshot) {
                  log('snapshot: ${snapshot.data}');
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No Messages found'),
                      // child: CupertinoActivityIndicator(),
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

                      // Check if the message is an image
                      if (image.toString() == 'image_type') {
                        return InkWell(
                          onTap: () {
                            // Get.to(
                            //   () => ImagePreview(
                            //     image:
                            //         'https://4077-119-73-114-193.ngrok-free.app$message',
                            //   ),
                            // );
                          },
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: sender == 'Me'
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: sender == 'Me'
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      height: 250,
                                      width: 250,
                                      decoration: BoxDecoration(
                                        color: sender == 'Me'
                                            ? primartColor
                                            : chatCardColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: FullScreenWidget(
                                          backgroundColor:
                                              const Color(0xFF000000),
                                          disposeLevel: DisposeLevel.High,
                                          child: Hero(
                                            tag: "customTag",
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  'https://4077-119-73-114-193.ngrok-free.app$message',
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CupertinoActivityIndicator(),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
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
                            ],
                          ),
                        );
                      } else if (image.toString() == 'audio_type') {
                        return Container(
                          width: 50,
                          padding: sender == 'Me'
                              ? const EdgeInsets.only(
                                  left: 50, top: 5, bottom: 5)
                              : const EdgeInsets.only(
                                  right: 50, top: 5, bottom: 5),
                          child: Column(
                            crossAxisAlignment: sender == 'Me'
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              VoiceMessageView(
                                backgroundColor: sender == 'Me'
                                    ? primartColor
                                    : chatCardColor,
                                circlesColor: sender == 'Me'
                                    ? greyColor
                                    : primaryFontColor,

                                activeSliderColor: sender == 'Me'
                                    ? whiteColor
                                    : primaryFontColor,
                                // size: 40,
                                counterTextStyle: TextStyle(
                                  color: sender == 'Me'
                                      ? whiteColor
                                      : primaryFontColor,
                                  fontSize: 12,
                                  fontFamily: circularStdBook,
                                ),
                                innerPadding: 10,
                                controller: VoiceController(
                                  audioSrc:
                                      'https://4077-119-73-114-193.ngrok-free.app$message',
                                  maxDuration: const Duration(milliseconds: 1),
                                  isFile: false,
                                  onComplete: () {},
                                  onPause: () {},
                                  onPlaying: () {},
                                  onError: (err) {
                                    log('Error: $err');
                                  },
                                ),
                              ),
                              Text(
                                timestamp.toString(),
                                textAlign: sender == 'Me'
                                    ? TextAlign.end
                                    : TextAlign.start,
                                style: const TextStyle(
                                  color: greyColor,
                                  fontSize: 10,
                                  fontFamily: circularStdBook,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (image.toString() == 'document_type') {
                        //document preview ui
                        return Align(
                          alignment: sender == 'Me'
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color:
                                  sender == 'Me' ? primartColor : chatCardColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextButton(
                              onPressed: () {
                                //     });
                                openDocument(context, message);
                              },
                              child: const Text(
                                'Document',
                                style: TextStyle(
                                  color: whiteColor,
                                  fontSize: 12,
                                  fontFamily: circularStdBook,
                                ),
                              ),
                            ),
                          ),
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
                                        borderRadius: BorderRadius.circular(10),
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
                        return bottomModalSheet(
                            chatController, context, _channel, widget.username);
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
                    readOnly: isRecording,
                    onFieldSubmitted: (value) {
                      chatController.isWriting.value = false;
                      log('value: ${chatController.isWriting.value}');
                    },
                    // controller: chatController.messageController,
                    controller: _controller,
                    cursorColor: secondaryFontColor,
                    onChanged: (value) => chatController.isWriting.value = true,
                    decoration: InputDecoration(
                      fillColor: lightgreyColor,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      filled: true,
                      hintText:
                          isRecording ? 'Recording...' : 'Write your message',
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
                              _channel.sink.add(
                                jsonEncode({
                                  'type': 'text_type',
                                  'username': widget.username,
                                  'message': _controller.text,
                                }),
                              );
                              log('message sent');
                              scrollToBottom();
                              chatController.isWriting.value = false;

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
                        )
                      : Row(
                          children: [
                            isRecording
                                ? Container()
                                : InkWell(
                                    onTap: () {
                                      chatController.pickImage(
                                          context,
                                          ImageSource.camera,
                                          _channel,
                                          widget.username);
                                    },
                                    child: const Icon(
                                      CupertinoIcons.camera,
                                      color: primaryFontColor,
                                    ),
                                  ),
                            const SizedBox(width: 15),
                            InkWell(
                              onTap: () {
                                log('isRecording: $isRecording');
                                //vibrate
                                HapticFeedback.vibrate();
                                setState(() {
                                  isRecording
                                      ? stopRecording()
                                      : startRecording();
                                });
                              },
                              child: Container(
                                padding: isRecording
                                    ? const EdgeInsets.all(8.0)
                                    : const EdgeInsets.all(0.0),
                                decoration: BoxDecoration(
                                  color: isRecording
                                      ? primartColor
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(1000),
                                ),
                                child: Icon(
                                  CupertinoIcons.mic,
                                  color: isRecording
                                      ? whiteColor
                                      : primaryFontColor,
                                  size: isRecording ? 30 : 25,
                                  // fill: isRecording ? 10.0 : 0.0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                        ),
                ),
                // const SizedBox(width: 20),
              ],
            ),
          )
        ],
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
}
