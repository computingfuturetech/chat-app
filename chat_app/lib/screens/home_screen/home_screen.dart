import 'package:chat_app/utils/colors.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(
            fontFamily: carosMedium,
            fontSize: 20,
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
            Icons.search,
            color: whiteColor,
          ),
        ),
        actions: [
          IconButton.outlined(
            onPressed: () {
              // Get.to(() => const ProfileSettingScreen());
            },
            icon: Image.asset('assets/images/p1.png'),
          ),
        ],
      ),
      body: const Center(
        child: Text('Home Screen'),
      ),
    );
  }
}
