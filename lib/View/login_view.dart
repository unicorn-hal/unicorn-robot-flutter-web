import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/login_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_textfield.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    LoginController controller = LoginController();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.images.icons.unicorn.image(
              width: 350,
              height: 350,
            ),
            SizedBox(
              width: 300,
              child: CustomTextfield(
                maxLines: 1,
                hintText: 'Email',
                controller: controller.emailController,
                width: 300,
                obscureText: false,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: CustomTextfield(
                maxLines: 1,
                hintText: 'Password',
                controller: controller.passwordController,
                width: 300,
                obscureText: true,
              ),
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'ログイン',
              onTap: () async {
                await controller.login(context);
              },
            ),
            const SizedBox(height: 150),
          ],
        ),
      ),
    );
  }
}
