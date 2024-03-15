import 'dart:developer';

import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/models/user_model/friend_request.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
                              child: SpinKitCircle(
                                color: primartColor,
                                size: 50,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
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

                                      return Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 4,
                                                left: 8,
                                                right: 8,
                                                bottom: 4),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                    color: whiteColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1000),
                                                  ),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1000),
                                                      child: CachedNetworkImage(
                                                          placeholder:
                                                              (context, url) =>
                                                                  const Center(
                                                                    child:
                                                                        CupertinoActivityIndicator(),
                                                                  ),
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              const Icon(
                                                                  Icons.error),
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.cover,
                                                          imageUrl: friendRequest
                                                                  .imageUrl ??
                                                              ''),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${friendRequest.firstName ?? ''} ${friendRequest.lastName ?? ''}',
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontFamily: carosMedium,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      friendRequest.bio ?? '',
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            circularStdBook,
                                                        fontSize: 12,
                                                        color: greyColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                IconButton.outlined(
                                                  iconSize: 20,
                                                  style: ButtonStyle(
                                                    maximumSize:
                                                        MaterialStateProperty
                                                            .all(
                                                      const Size(40, 40),
                                                    ),
                                                    side: MaterialStateProperty
                                                        .all(
                                                      const BorderSide(
                                                        color: greenColor,
                                                        width: 1.0,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    userController
                                                        .acceptFriendRequest(
                                                            friendRequest
                                                                .fromUserId);
                                                  },
                                                  icon: const Icon(
                                                      CupertinoIcons.checkmark),
                                                  color: greenColor,
                                                ),
                                                IconButton.outlined(
                                                  iconSize: 20,
                                                  style: ButtonStyle(
                                                    side: MaterialStateProperty
                                                        .all(
                                                      const BorderSide(
                                                        color: redColor,
                                                        width: 1.0,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      CupertinoIcons.xmark),
                                                  color: redColor,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(
                                            height: 20,
                                            thickness: 0.5,
                                            color: grey2Color,
                                          ),
                                        ],
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
