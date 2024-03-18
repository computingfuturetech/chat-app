import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AuthController());
    return Scaffold(
      backgroundColor: primaryFontColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customAppBar(
          title: 'Settings',
          imageUrl: '',
          isIcon: false,
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
            Container(
              margin: const EdgeInsets.only(top: 20),
              height: 4,
              width: 40,
              decoration: const BoxDecoration(
                color: grey2Color,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              // imageUrl: controller.user.value.profilePic,
                              imageUrl: controller.image.value,
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.username.value,
                                style: const TextStyle(
                                  color: primaryFontColor,
                                  fontFamily: carosBold,
                                  fontSize: 20,
                                ),
                              ),
                              const Text(
                                'Never give up',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
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
                          Icons.key_outlined,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Account',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Privacy, security, change number',
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          CupertinoIcons.chat_bubble,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Chat',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Chat history,theme,wallpapers',
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          CupertinoIcons.bell,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Messages, group and others',
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          Icons.help_outline_outlined,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Help',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Help center, contact us, privacy policy',
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          Icons.data_usage_sharp,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Storage and data',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Network usage, storage usage',
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          CupertinoIcons.person_2,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Invite a friend',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        controller.logout();
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: settingsCardColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(
                          Icons.logout_outlined,
                          color: greyColor,
                        ),
                      ),
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          fontFamily: carosMedium,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
