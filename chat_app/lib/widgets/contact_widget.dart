import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

Widget contactUser(
  user,
  userController,
) {
  return Column(
    children: [
      Container(
        margin: const EdgeInsets.only(top: 4, left: 8, right: 8, bottom: 4),
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => const Center(
                      child: CupertinoActivityIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                userController.sendFriendRequest(user.id!);
              },
              icon: const Icon(CupertinoIcons.person_add),
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
}
