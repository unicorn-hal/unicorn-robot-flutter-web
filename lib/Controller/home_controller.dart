import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  BuildContext context;
  HomeController(
    this.context,
  ) {
    Log.echo('HomeController');
  }

  @override
  initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthState();
    });
    Log.echo('initialize');
  }

  void checkAuthState() {
    final User? currentRobot = _firebaseAuthenticationService.getRobot();
    if (currentRobot == null) {
      const LoginRoute().go(context);
    }
  }

  void logout() {
    _firebaseAuthenticationService.signOut();
    const LoginRoute().go(context);
  }
}
