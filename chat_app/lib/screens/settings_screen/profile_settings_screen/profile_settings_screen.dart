import 'package:flutter/material.dart';

class ProfileSettingScreen extends StatelessWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setting Screen'),
      ),
      body: const Center(
        child: Text('Profile Setting Screen'),
      ),
    );
  }
}
