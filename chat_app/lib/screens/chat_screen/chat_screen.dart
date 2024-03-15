import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var chatController = Get.put(ChatController());
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
                                const Icon(Icons.error),
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                            imageUrl:
                                'https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg'),
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
              const Column(
                children: [
                  Text(
                    'John Doe',
                    style: TextStyle(
                      color: primaryFontColor,
                      fontSize: 14,
                      fontFamily: carosMedium,
                    ),
                  ),
                  Text(
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                physics: const BouncingScrollPhysics(),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: index % 2 == 0
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: index % 2 == 0
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? primartColor
                                        : chatCardColor,
                                    borderRadius: index % 2 == 0
                                        ? const BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          )
                                        : const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                  ),
                                  child: Text(
                                    'Hello',
                                    style: TextStyle(
                                      color: index % 2 == 0
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
                            const Text(
                              '12:00 PM',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                color: greyColor,
                                fontSize: 10,
                                fontFamily: circularStdBook,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: lightgreyColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Today',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: primaryFontColor,
                            fontSize: 10,
                            fontFamily: carosMedium,
                          ),
                        ),
                      ),
                    ],
                  );
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
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  height: 4,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: grey2Color,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(20),
                                    ),
                                  ),
                                ),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // const SizedBox(width: 20),
                                    // Align(
                                    //   alignment: Alignment.topLeft,
                                    //   child: InkWell(
                                    //     onTap: () {
                                    //       Get.back();
                                    //     },
                                    //     child: const Icon(
                                    //       Icons.close,
                                    //       color: primaryFontColor,
                                    //     ),
                                    //   ),
                                    // ),
                                    Text(
                                      'Share Content',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: primaryFontColor,
                                        fontSize: 16,
                                        fontFamily: carosMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {
                                    chatController.pickImage(
                                        context, ImageSource.camera);
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: settingsCardColor,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.camera,
                                      color: greyColor,
                                    ),
                                  ),
                                  title: const Text(
                                    'Camera',
                                    style: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {
                                    chatController.documentPicker(context);
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: settingsCardColor,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: const Icon(
                                      // Icons.insert_drive_file_outlined,
                                      CupertinoIcons.doc_text,
                                      color: greyColor,
                                    ),
                                  ),
                                  title: const Text(
                                    'Documents',
                                    style: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Share your files',
                                    style: TextStyle(
                                      fontFamily: circularStdBook,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {
                                    chatController.filePicker(context);
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: settingsCardColor,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: const Icon(
                                      Icons.bar_chart_rounded,
                                      color: greyColor,
                                    ),
                                  ),
                                  title: const Text(
                                    'Media',
                                    style: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Share photos and videos',
                                    style: TextStyle(
                                      fontFamily: circularStdBook,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {
                                    Get.to(() => const ProfileSettingScreen(),
                                        transition: Transition.rightToLeft);
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: settingsCardColor,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.person_circle,
                                      color: greyColor,
                                    ),
                                  ),
                                  title: const Text(
                                    'Contact',
                                    style: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Share your contacts',
                                    style: TextStyle(
                                      fontFamily: circularStdBook,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListTile(
                                  onTap: () {
                                    Get.to(() => const ProfileSettingScreen(),
                                        transition: Transition.rightToLeft);
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: settingsCardColor,
                                      borderRadius: BorderRadius.circular(1000),
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      color: greyColor,
                                    ),
                                  ),
                                  title: const Text(
                                    'Location',
                                    style: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Share your location',
                                    style: TextStyle(
                                      fontFamily: circularStdBook,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Icon(
                      Icons.attach_file,
                      color: primaryFontColor,
                    ),
                  ),

                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
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
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          chatController.pickImage(context, ImageSource.camera);
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
