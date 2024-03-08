import 'package:chat_app/screens/chat_screen/chat_screen.dart';
import 'package:chat_app/screens/settings_screen/profile_settings_screen/profile_settings_screen.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //init home controller
    var controller = Get.put(HomeController());

    var navbarItem = [
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.chat_bubble_text), label: 'Messages'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.call_outlined), label: 'Calls'),
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.profile_circled), label: 'Contacts'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined), label: 'Settings'),
    ];

    var navBody = [
      const HomeScreen(),
      const ChatScreen(),
      const ProfileSettingScreen(),
      const SettingScreen(),
    ];

    return Scaffold(
      body: Column(
        children: [
          Obx(() => Expanded(
              child: navBody.elementAt(controller.currentNavIndex.value))),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          unselectedLabelStyle: const TextStyle(
            fontFamily: carosMedium,
            fontSize: 12,
          ),
          currentIndex: controller.currentNavIndex.value,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: secondaryFontColor,
          // selectedIconTheme: const IconThemeData(color: secondaryFontColor),
          unselectedItemColor: Colors.grey[500],
          selectedLabelStyle: const TextStyle(
            fontFamily: carosMedium,
            fontSize: 12,
          ),
          backgroundColor: whiteColor,
          items: navbarItem,
          onTap: (value) {
            controller.currentNavIndex.value = value;
          },
        ),
      ),
    );
  }
}
