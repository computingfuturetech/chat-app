import 'dart:developer';

import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/models/chat_room/chat_room.dart';
import 'package:chat_app/screens/chat_screen/ai_chat_screen.dart';
import 'package:chat_app/screens/home_screen/search_screen.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/home_screen_users.dart';
import 'package:shimmer_pro/shimmer_pro.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    final authController = Get.find<AuthController>();
    List<Chatroom> localChatRooms = [];
    bool dataLoaded = false;

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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          log(controller.aiChatRoomIds.value.toString());
          Get.to(() => AIChatScreen(
                username: 'AI',
                chatRoomId: controller.aiChatRoomIds.value.toString(),
                secondUserId: '2',
              ));
        },
        backgroundColor: greenColor,
        tooltip: 'Chat with AI',
        child: const Icon(
          Icons.chat_rounded,
          color: whiteColor,
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      if (localChatRooms.isEmpty) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                ShimmerPro.sized(
                                    scaffoldBackgroundColor: blackColor,
                                    height: 50,
                                    width: 50),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShimmerPro.sized(
                                      scaffoldBackgroundColor: blackColor,
                                      height: 10,
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                    ),
                                    ShimmerPro.sized(
                                      scaffoldBackgroundColor: blackColor,
                                      height: 10,
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Show the local data until new data is fetched
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: localChatRooms.length,
                          itemBuilder: (context, index) {
                            final chatRoom = localChatRooms[index];
                            return index == 0
                                ? Container()
                                : homeUsers(
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
                      // final chatRooms = snapshot.data;
                      localChatRooms = snapshot.data!;
                      dataLoaded = true;
                      return Obx(() {
                        final chatRooms = snapshot.data!;
                        final isLoading = controller.isHomeScreenLoading.value;
                        return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final chatRoom = chatRooms[index];

                              return index == 0
                                  ? Container()
                                  : homeUsers(
                                      '${chatRoom.membersInfo[0].firstName} ${chatRoom.membersInfo[0].lastName}',
                                      chatRoom.membersInfo[0].bio,
                                      chatRoom.id.toString(),
                                      '$baseUrl${chatRoom.membersInfo[0].image}',
                                      chatRoom.lastMessage.message,
                                      chatRoom.membersInfo.first.id.toString(),
                                    );
                            });
                      });
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
