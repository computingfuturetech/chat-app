// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:chat_app/utils/exports.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LargeButton extends StatelessWidget {
  final title, onPressed, backgroundColor, textColor, controller;

  const LargeButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor = whiteColor,
    this.textColor = primaryFontColor,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(top: 14, bottom: 10),
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: onPressed,
          child: controller.isLoading.value
              ? SpinKitCircle(
                  color: textColor,
                  size: 22,
                )
              : Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: carosMedium,
                  ),
                ),
        ),
      ),
    );
  }
}
