import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = HomeController(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'WELCOME TO UNICORN ROBOT HOME VIEW',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'ログアウト',
              onTap: () {
                controller.logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
