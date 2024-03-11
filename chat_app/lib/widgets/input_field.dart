// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:chat_app/utils/exports.dart';

class InputField extends StatelessWidget {
  final label,
      hintText,
      validator,
      controller,
      keyboardType,
      textCapitalization,
      obsecureText;
  const InputField(
      {super.key,
      required this.label,
      required this.hintText,
      required this.validator,
      required this.controller,
      required this.keyboardType,
      required this.textCapitalization,
      this.obsecureText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: circularStdMedium,
                  fontSize: 14,
                  color: secondaryFontColor,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Text(
                '*',
                style: TextStyle(
                  fontFamily: circularStdMedium,
                  fontSize: 14,
                  color: redColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: 72, // Set a fixed height here
          child: TextFormField(
            obscureText: obsecureText ?? false,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            controller: controller,
            validator: validator,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              hintText: hintText,
              hintStyle: const TextStyle(
                color: greyColor,
                fontSize: 14,
                fontFamily: circularStdBook,
              ),
              isDense: true, // Ensures the border height remains the same
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: secondaryFontColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: greyColor,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: redColor,
                ),
              ),
              errorStyle: const TextStyle(
                color: redColor,
                fontSize: 12,
                fontFamily: circularStdBook,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
