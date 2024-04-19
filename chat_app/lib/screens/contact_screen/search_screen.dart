
import 'package:chat_app/controllers/user_controller/user_controller.dart';
import 'package:chat_app/utils/exports.dart';
import 'package:chat_app/widgets/search_appbar.dart';

class ContactSearchScreen extends StatelessWidget {
  const ContactSearchScreen({super.key});


  @override
  Widget build(BuildContext context) {
    var userController = Get.put(UserController());
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: searchAppBar(context, userController.contactSearchController),
      ),
      body: Obx(() {
        if (userController.users.isEmpty) {
          return const Center(
            child: Text('No results found'),
          );
        } else {
          return ListView.builder(
            itemCount: userController.users.length,
            itemBuilder: (context, index) {
              User user = userController.users[index];
              return contactUser(user, userController);
            },
          );
        }
      }),
    );
  }
}
