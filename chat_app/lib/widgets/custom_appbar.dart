import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

Widget customAppBar({
  required String title,
  required imageUrl,
  required bool isIcon,
  searchOnPressed,
}) {
  return AppBar(
    title: Text(
      title,
      style: const TextStyle(
        fontFamily: carosMedium,
        fontSize: 18,
        color: whiteColor,
      ),
    ),
    centerTitle: true,
    backgroundColor: primaryFontColor,
    leading: imageUrl != ''
        ? IconButton.outlined(
            // onPressed: () {
            //   Get.to(() => const HomeSearchScreen());
            // },
            onPressed: searchOnPressed,
            icon: const Icon(
              size: 20,
              Icons.search,
              color: whiteColor,
            ),
          )
        : null,
    actions: [
      isIcon
          ? IconButton.outlined(
              onPressed: () {},
              icon: Icon(
                imageUrl,
                color: whiteColor,
                size: 20,
              ),
            )
          : imageUrl != ''
              ? imageUrl == null
                  ? Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: lightgreyColor,
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: primaryFontColor,
                        size: 30,
                      ))
                  : InkWell(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => const Center(
                            child: CupertinoActivityIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            color: whiteColor,
                          ),
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                          imageUrl: imageUrl,
                        ),
                      ),
                    )
              : Container(),
    ],
  );
}
