import 'dart:developer';

import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:chat_app/screens/home_screen/search_screen.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/home_screen_users.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final authController = Get.put(AuthController()); 
    return Scaffold(
      backgroundColor: primaryFontColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customAppBar(
          title: 'Messages',
          imageUrl: authController.image.value,
          isIcon: false,
          searchOnPressed: () {
            Get.to(
              () => const HomeSearchScreen(),
              transition: Transition.noTransition,
            );
          },
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
                child: StreamBuilder<List<Chatroom>>(
                  stream: controller.fetchChatRoomsData(),
                  builder: (context, snapshot) {
                    log('snapshot: ${snapshot.data}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SpinKitFadingCircle(
                        color: greenColor,
                        size: 50,
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No results found'),
                      );
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error fetching data'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No data found'),
                      );
                    } else {
                      final chatRooms = snapshot.data;
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final chatRoom = chatRooms![index];
                          return homeUsers(
                            '${chatRoom.membersInfo[0].firstName} ${chatRoom.membersInfo[0].lastName}',
                            chatRoom.membersInfo[0].bio,
                            chatRoom.id.toString(),
                            '$baseUrl${chatRoom.membersInfo[0].image}',
                            chatRoom.lastMessage.message,
                            chatRoom.membersInfo.first.id.toString(),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void doNothing(BuildContext context) {}
