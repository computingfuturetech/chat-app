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
        TextFormField(
          obscureText: obsecureText ?? false,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: greyColor,
              fontSize: 14,
              fontFamily: circularStdBook,
            ),
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
          ),
        ),
      ],
    );
  }
}
