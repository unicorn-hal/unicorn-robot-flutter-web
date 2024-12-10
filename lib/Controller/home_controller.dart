import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_request.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_response.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Unicorn/unicorn_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  TextEditingController movingUserIdController = TextEditingController();
  TextEditingController movingRobotLatitudeController = TextEditingController();
  TextEditingController movingRobotLongitudeController =
      TextEditingController();

  TextEditingController arrivalUserIdController = TextEditingController();
  TextEditingController arrivalRobotLatitudeController =
      TextEditingController();
  TextEditingController arrivalRobotLongitudeController =
      TextEditingController();

  TextEditingController completeUserIdController = TextEditingController();
  TextEditingController completeRobotSupportIdController =
      TextEditingController();
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

  /// 移動通知
  Future<UnicornLocation?> postMovingUnicorn() async {
    if (movingUserIdController.text.isEmpty ||
        movingRobotLatitudeController.text.isEmpty ||
        movingRobotLongitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("未入力の項目があります"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    final String userId = movingUserIdController.text.trim();
    final double robotLatitude =
        double.parse(movingRobotLatitudeController.text);
    final double robotLongitude =
        double.parse(movingRobotLongitudeController.text);

    final UnicornLocation body = UnicornLocation(
      userId: userId,
      robotLatitude: robotLatitude,
      robotLongitude: robotLongitude,
    );

    final UnicornLocation? response = await UnicornApi().postMovingUnicorn(
      body: body,
      robotId: _firebaseAuthenticationService.getUid()!,
    );

    return response;
  }

  /// 到着通知
  Future<UnicornLocation?> postArrivalUnicorn() async {
    if (arrivalUserIdController.text.isEmpty ||
        arrivalRobotLatitudeController.text.isEmpty ||
        arrivalRobotLongitudeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("未入力の項目があります"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    final String userId = arrivalUserIdController.text.trim();
    final double robotLatitude =
        double.parse(arrivalRobotLatitudeController.text);
    final double robotLongitude =
        double.parse(arrivalRobotLongitudeController.text);

    final UnicornLocation body = UnicornLocation(
      userId: userId,
      robotLatitude: robotLatitude,
      robotLongitude: robotLongitude,
    );

    final UnicornLocation? response = await UnicornApi().postArrivalUnicorn(
      body: body,
      robotId: _firebaseAuthenticationService.getUid()!,
    );

    return response;
  }

  /// 完了通知
  Future<UnicornSupport?> postCompleteUnicorn() async {
    if (completeUserIdController.text.isEmpty ||
        completeRobotSupportIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("未入力の項目があります"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }
    final String userId = completeUserIdController.text.trim();
    final String robotSupportId = completeRobotSupportIdController.text.trim();

    final UnicornSupport body = UnicornSupport(
      userId: userId,
      robotSupportId: robotSupportId,
    );

    final UnicornSupport? response = await UnicornApi().postCompleteUnicorn(
      body: body,
      robotId: _firebaseAuthenticationService.getUid()!,
    );

    return response;
  }
}
