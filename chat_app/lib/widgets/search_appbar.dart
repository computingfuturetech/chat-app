import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/utils/exports.dart';

Widget searchAppBar(
  context,
  controller,
) {
  var userController = Get.put(UserController());
  return AppBar(
    automaticallyImplyLeading: false,
    title: TextFormField(
      controller: controller,
      cursorColor: primaryFontColor,
      autofocus: true,
      onChanged: (value) {
        userController.fetchContactSearchData(value);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10),
        filled: true,
        fillColor: lightgreyColor,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        hintText: 'Search',
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: subtitleColor,
          fontSize: 14,
          fontFamily: circularStdMedium,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: subtitleColor,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.close,
            color: subtitleColor,
          ),
        ),
      ),
      style: const TextStyle(
        color: primaryFontColor,
        fontSize: 14,
        fontFamily: circularStdMedium,
      ),
    ),
  );
}
