import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

Widget bottomModalSheet (
  chatController, context,
){
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
                        
}