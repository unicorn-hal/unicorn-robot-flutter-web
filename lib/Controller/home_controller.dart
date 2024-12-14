import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
import 'package:video_player/video_player.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  late VideoPlayerController videoPlayerController;
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

  void initializeVideoPlayer(VoidCallback onInitialized) {
    videoPlayerController = VideoPlayerController.asset(
      Assets.videos.unicornShort,
    )
      ..setLooping(true)
      ..initialize().then((_) {
        // 初期化が完了したら再描画してビデオを再生
        onInitialized();
        videoPlayerController.setVolume(0.0);
        videoPlayerController.play();
      });
  }

  void dispose() {
    videoPlayerController.dispose();
  }
}
