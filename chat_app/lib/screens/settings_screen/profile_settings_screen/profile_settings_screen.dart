import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class ProfileSettingScreen extends StatelessWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
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

                    imageUrl: '$baseUrl${authController.image.value}',
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      color: whiteColor,
                      size: 30,
                    ),
                  ),
                ),
                Text(
                  // controller.user.value.name,
                  authController.username.value,
                  style: const TextStyle(
                    color: whiteColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authController.email.value,
                  style: const TextStyle(
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
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Display Name',
                                  style: TextStyle(
                                    fontFamily: circularStdBook,
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),
                                TextFormField(
                                  initialValue: authController.username.value,
                                  // onChanged: (value) {
                                  //   authController.username.value = value;
                                  // },
                                  style: const TextStyle(
                                    fontFamily: carosMedium,
                                    fontSize: 18,
                                    color: primaryFontColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'Enter your name',
                                    hintStyle: TextStyle(
                                      fontFamily: circularStdMedium,
                                      fontSize: 18,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ),
                                // Text(
                                //   authController.username.value,
                                //   // 'Jhon Abraham',
                                //   style: const TextStyle(
                                //     fontFamily: carosMedium,
                                //     fontSize: 18,
                                //     color: primaryFontColor,
                                //   ),
                                // ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Email Address',
                                  style: TextStyle(
                                    fontFamily: circularStdBook,
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),
                                // Text(
                                //   // controller.user.value.email,
                                //   authController.email.value,

                                //   style: const TextStyle(
                                //     fontFamily: carosMedium,
                                //     fontSize: 18,
                                //     color: primaryFontColor,
                                //   ),
                                // ),
                                TextFormField(
                                  initialValue: authController.email.value,
                                  onChanged: (value) {
                                    authController.username.value = value;
                                  },
                                  style: const TextStyle(
                                    fontFamily: circularStdMedium,
                                    fontSize: 18,
                                    color: primaryFontColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'Enter your name',
                                    hintStyle: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 18,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                // const Text(
                                //   'Address',
                                //   style: TextStyle(
                                //     fontFamily: circularStdBook,
                                //     fontSize: 14,
                                //     color: subtitleColor,
                                //   ),
                                // ),
                                // const Text(
                                //   // controller.user.value.address,
                                //   '33 street west subidbazar, sylhet',
                                //   style: TextStyle(
                                //     fontFamily: carosMedium,
                                //     fontSize: 18,
                                //     color: primaryFontColor,
                                //   ),
                                // ),
                                // const SizedBox(height: 10),
                                const Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    fontFamily: circularStdBook,
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),

                                TextFormField(
                                  initialValue: authController.phone.value,
                                  onChanged: (value) {
                                    authController.phone.value = value;
                                  },
                                  style: const TextStyle(
                                    fontFamily: circularStdMedium,
                                    fontSize: 18,
                                    color: primaryFontColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'Enter your phone',
                                    hintStyle: TextStyle(
                                      fontFamily: circularStdMedium,
                                      fontSize: 18,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ),
                                // Text(
                                //   authController.phone.value,
                                //   style: const TextStyle(
                                //     fontFamily: carosMedium,
                                //     fontSize: 18,
                                //     color: primaryFontColor,
                                //   ),
                                // ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontFamily: circularStdBook,
                                    fontSize: 14,
                                    color: subtitleColor,
                                  ),
                                ),

                                TextFormField(
                                  initialValue: authController.bio.value,
                                  onChanged: (value) {
                                    authController.bio.value = value;
                                  },
                                  maxLines: 10,
                                  minLines: 5,
                                  style: const TextStyle(
                                    fontFamily: circularStdMedium,
                                    fontSize: 18,
                                    color: primaryFontColor,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    hintText: 'Enter your bio',
                                    hintStyle: TextStyle(
                                      fontFamily: carosMedium,
                                      fontSize: 18,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                LargeButton(
                                  title: 'Update',
                                  onPressed: () {},
                                  controller: authController,
                                  backgroundColor: blackColor,
                                  textColor: whiteColor,
                                ),
                                // Text(
                                //   authController.bio.value,
                                //   style: const TextStyle(
                                //     fontFamily: carosMedium,
                                //     fontSize: 18,
                                //     color: primaryFontColor,
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
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
