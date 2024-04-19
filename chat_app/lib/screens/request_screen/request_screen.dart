import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/request_users.dart';
import 'package:flutter/cupertino.dart';

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var userController = Get.put(UserController());
    return Scaffold(
      backgroundColor: primaryFontColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: customAppBar(
          title: 'Request',
          imageUrl: CupertinoIcons.person_add,
          isIcon: true,
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
                    const Text(
                      'People',
                      style: TextStyle(
                        fontFamily: carosMedium,
                        fontSize: 20,
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<FriendRequest>>(
                        stream: userController.fetchRequestData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: SpinKitFadingCircle(
                                color: greenColor,
                                size: 50,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child:
                                  Text('Error loading data. Please try again'),
                            );
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text('No requests found'),
                            );
                          } else {
                            final List<FriendRequest> users = snapshot.data!;

                            return users.isEmpty
                                ? const Center(
                                    child: Text('No requests found'),
                                  )
                                : ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: users.length,
                                    itemBuilder: (context, index) {
                                      final friendRequest = users[index];

                                      return requestUser(
                                        friendRequest,
                                        userController,
                                      );
                                    },
                                  );
                          }
                        },
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
