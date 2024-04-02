import 'package:chat_app/utils/exports.dart';
import 'package:flutter/cupertino.dart';
import 'package:full_screen_image/full_screen_image.dart';

class ImagePreview extends StatelessWidget {
  final image;
  const ImagePreview({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: greyColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      )),
      body: FullScreenWidget(
        backgroundColor: Colors.black,
        disposeLevel: DisposeLevel.High,
        child: Center(
          child: Hero(
            tag: "customTag",
            child: CachedNetworkImage(
              imageUrl: image,
              placeholder: (context, url) => const Center(
                child: CupertinoActivityIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
