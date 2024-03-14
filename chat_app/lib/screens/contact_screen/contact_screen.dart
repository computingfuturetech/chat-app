import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) {
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
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              height: 50,
                                              width: 50,
                                              fit: BoxFit.cover,
                                              imageUrl:
                                                  'https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg'),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'John Doe',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: carosMedium,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Hey, how are you?',
                                          maxLines: 1,
                                          style: TextStyle(
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
                                      onPressed: () {},
                                      icon:
                                          const Icon(CupertinoIcons.person_add),
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
