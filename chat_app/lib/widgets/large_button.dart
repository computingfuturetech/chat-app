import 'package:chat_app/utils/exports.dart';

class LargeButton extends StatelessWidget {
  final title, onPressed, backgroundColor, textColor;

  const LargeButton({
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
          padding: const EdgeInsets.only(top: 18, bottom: 14),
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
