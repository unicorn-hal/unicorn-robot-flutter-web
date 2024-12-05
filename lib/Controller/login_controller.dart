import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class LoginController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  LoginController();

  Future<void> login(BuildContext context) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // FirebaseAuth を使ったサインイン
    final bool isSuccess =
        await _firebaseAuthenticationService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (isSuccess) {
      // サインイン成功時
      Log.echo('サインイン成功： $email');
      if (context.mounted) {
        const HomeRoute().go(context); // 画面遷移
      }
    } else {
      // サインイン失敗時
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("メールアドレスまたはパスワードが間違っています"),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
