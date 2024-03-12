import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: CustomAppBar(
            title: 'Home',
            imageUrl: p1,
          )),
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
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                              top: 4, left: 8, right: 8, bottom: 4),
                          child: InkWell(
                            onTap: () => Get.to(() => const ChatScreen(),
                                transition: Transition.rightToLeft),
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
                                          borderRadius:
                                              BorderRadius.circular(1000),
                                          child: CachedNetworkImage(
                                              placeholder: (context, url) =>
                                                  const Center(
                                                    child:
                                                        CupertinoActivityIndicator(),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  'https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg'),
                                        ),
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(1000),
                                            ),
                                            child: Center(
                                              child: Container(
                                                height: 15,
                                                width: 15,
                                                decoration: BoxDecoration(
                                                  color: greenColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1000),
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
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Name',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: carosMedium,
                                        fontSize: 16,
                                        color: primaryFontColor,
                                      ),
                                    ),
                                    Text(
                                      'subtitle',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
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
                                        color: redColor,
                                        borderRadius:
                                            BorderRadius.circular(1000),
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
                        const Divider(
                          height: 20,
                          thickness: 0.5,
                          color: grey2Color,
                        ),
                      ],
                    );
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
