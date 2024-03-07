import 'package:chat_app/utils/exports.dart';

class PasswordInputField extends StatefulWidget {
  final label, hintText, validator, controller;
  const PasswordInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.validator,
    required this.controller,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool obsecure = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            children: [
              Text(
                widget.label,
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
          obscureText: obsecure,
          keyboardType: TextInputType.visiblePassword,
          textCapitalization: TextCapitalization.none,
          controller: widget.controller,
          validator: widget.validator,
          decoration: InputDecoration(
            suffixIcon: obsecure
                ? IconButton(
                    onPressed: () {
                      obsecure = !obsecure;
                      setState(() {});
                    },
                    icon: Image.asset(icPassHide, width: 20),
                    color: blackColor,
                  )
                : IconButton(
                    onPressed: () {
                      obsecure = !obsecure;
                      setState(() {});
                    },
                    icon: Image.asset(icPassShow, width: 20),
                    color: blackColor,
                  ),
            hintText: widget.hintText,
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
