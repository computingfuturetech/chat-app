import 'package:chat_app/utils/exports.dart';

Widget CustomAppBar({
  required String title,
  required String imageUrl,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: carosMedium,
        fontSize: 18,
        color: whiteColor,
      ),
    ),
    centerTitle: true,
    backgroundColor: secondaryColor,
    leading: IconButton.outlined(
      onPressed: () {
        // Get.to(() => const ProfileSettingScreen());
      },
      icon: const Icon(
        size: 20,
        Icons.search,
        color: whiteColor,
      ),
    ),
    actions: [
      IconButton.outlined(
        onPressed: () {
          // Get.to(() => const ProfileSettingScreen());
        },
        icon: Image.asset(imageUrl),
      ),
    ],
  );
}
