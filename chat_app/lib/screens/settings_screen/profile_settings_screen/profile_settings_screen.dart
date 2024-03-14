import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class ProfileSettingScreen extends StatelessWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: primaryFontColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(250),
          child: Container(
            color: primaryFontColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      // Get.to(() => const ProfileSettingScreen());
                      Get.back();
                    },
                    child: const Icon(
                      CupertinoIcons.arrow_left,
                      color: whiteColor,
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                    // imageUrl: controller.user.value.profilePic,
                    imageUrl:
                        'https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const Text(
                  // controller.user.value.name,
                  'Jhon Abraham',
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '@jhonabraham',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlackColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(CupertinoIcons.chat_bubble,
                            color: whiteColor)),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlackColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(CupertinoIcons.video_camera,
                            color: whiteColor)),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlackColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(CupertinoIcons.phone,
                            color: whiteColor)),
                    const SizedBox(width: 10),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlackColor,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                        child: const Icon(Icons.more_horiz, color: whiteColor)),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
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
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Display Name',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                // controller.user.value.name,
                                'Jhon Abraham',
                                style: TextStyle(
                                  fontFamily: carosMedium,
                                  fontSize: 18,
                                  color: primaryFontColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Email Address',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                // controller.user.value.email,
                                'jhonabraham20@gmail.com',
                                style: TextStyle(
                                  fontFamily: carosMedium,
                                  fontSize: 18,
                                  color: primaryFontColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Address',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                // controller.user.value.address,
                                '33 street west subidbazar, sylhet',
                                style: TextStyle(
                                  fontFamily: carosMedium,
                                  fontSize: 18,
                                  color: primaryFontColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                // controller.user.value.phone,
                                '(320) 555-0104',
                                style: TextStyle(
                                  fontFamily: carosMedium,
                                  fontSize: 18,
                                  color: primaryFontColor,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Bio',
                                style: TextStyle(
                                  fontFamily: circularStdBook,
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                              ),
                              Text(
                                'Never Give up',
                                style: TextStyle(
                                  fontFamily: carosMedium,
                                  fontSize: 18,
                                  color: primaryFontColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
