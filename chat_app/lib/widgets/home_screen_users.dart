import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

Widget homeUsers(
  username,
  bio,
  chatRoomId,
  imageUrl,
  lastMessage,
  secondUserId,
) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
        child: Slidable(
          // Specify a key if the Slidable is dismissible.

          key: const ValueKey(1),
          endActionPane: const ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                autoClose: true,
                onPressed: doNothing,
                // foregroundColor: Colors.white,
                // backgroundColor: primaryFontColor,\
                icon: CupertinoIcons.bell,
                spacing: 1,
              ),
              SlidableAction(
                onPressed: doNothing,
                autoClose: true,
                icon: CupertinoIcons.delete,
                foregroundColor: redColor,
                spacing: 1,
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Get.to(
                () => ChatScreen(
                  username: username,
                  image: imageUrl ?? 'https://via.placeholder.com/150',
                  chatRoomId: chatRoomId,
                  secondUserId: secondUserId,
                ),
                transition: Transition.rightToLeft,
              );
            },
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(1000),
                          child: imageUrl == null
                              ? Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    color: lightgreyColor,
                                    borderRadius: BorderRadius.circular(1000),
                                  ),
                                  child: const Icon(
                                    Icons.person,
                                    color: primaryFontColor,
                                    size: 30,
                                  ),
                                )
                              : CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.person),
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  imageUrl: imageUrl ??
                                      'https://via.placeholder.com/150',
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 15,
                            width: 15,
                            decoration: BoxDecoration(
                              color: whiteColor,
                              borderRadius: BorderRadius.circular(1000),
                            ),
                            child: Center(
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: greenColor,
                                  borderRadius: BorderRadius.circular(
                                    1000,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: carosMedium,
                        fontSize: 16,
                        color: primaryFontColor,
                      ),
                    ),
                    Text(
                      lastMessage ?? bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: circularStdBook,
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      '12:00 PM',
                      style: TextStyle(
                        fontFamily: circularStdBook,
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: primartColor,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      // padding: const EdgeInsets.all(4),
                      alignment: Alignment.center,
                      child: const Text(
                        // index.toString()
                        '4',
                        // textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: circularStdBook,
                          fontSize: 12,
                          color: whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      const Divider(
        height: 20,
        thickness: 0.5,
        color: grey2Color,
      ),
    ],
  );
}
