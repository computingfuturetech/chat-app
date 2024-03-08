// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:chat_app/utils/exports.dart';

class SimpleLargeButton extends StatelessWidget {
  final title, onPressed, backgroundColor, textColor;

  const SimpleLargeButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backgroundColor = whiteColor,
    this.textColor = primaryFontColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(top: 14, bottom: 10),
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontFamily: carosMedium,
          ),
        ),
      ),
    );
  }
}
