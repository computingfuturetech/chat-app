import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

Widget requestUser(
  friendRequest,
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
                          const Icon(Icons.error),
                      height: 50,
                      width: 50,
                      fit: BoxFit.cover,
                      imageUrl: friendRequest.imageUrl ?? ''),
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
                  '${friendRequest.firstName} ${friendRequest.lastName}',
                  maxLines: 1,
                  style: const TextStyle(
                    fontFamily: carosMedium,
                    fontSize: 16,
                  ),
                ),
                Text(
                  friendRequest.bio,
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
              style: ButtonStyle(
                maximumSize: MaterialStateProperty.all(
                  const Size(40, 40),
                ),
                side: MaterialStateProperty.all(
                  const BorderSide(
                    color: greenColor,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onPressed: () {
                userController.acceptFriendRequest(friendRequest.fromUserId);
              },
              icon: const Icon(CupertinoIcons.checkmark),
              color: greenColor,
            ),
            IconButton.outlined(
              iconSize: 20,
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  const BorderSide(
                    color: redColor,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              onPressed: () {},
              icon: const Icon(CupertinoIcons.xmark),
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
}
