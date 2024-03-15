import 'package:chat_app/models/user_model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/utils/exports.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

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
                      child: StreamBuilder<List<User>>(
                        stream: userController.fetchData(),
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
                            final List<User> users = snapshot.data!;
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 4, left: 8, right: 8, bottom: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(1000),
                                            ),
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(1000),
                                                child: CachedNetworkImage(
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child:
                                                        CupertinoActivityIndicator(),
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.person),
                                                  height: 50,
                                                  width: 50,
                                                  fit: BoxFit.cover,
                                                  imageUrl: user.image ?? '',
                                                ),
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
                                                '${user.firstName ?? ''} ${user.lastName ?? ''}',
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontFamily: carosMedium,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                user.bio ?? '',
                                                maxLines: 1,
                                                style: const TextStyle(
                                                  fontFamily: circularStdBook,
                                                  fontSize: 12,
                                                  color: greyColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          IconButton.outlined(
                                            iconSize: 20,
                                            onPressed: () {
                                              userController
                                                  .sendFriendRequest(user.id!);
                                            },
                                            icon: const Icon(
                                                CupertinoIcons.person_add),
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
