import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
import 'package:video_player/video_player.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  late VideoPlayerController videoPlayerController;
  final BuildContext context;

  // Google Maps JS ロード状態
  bool _googleMapsJsLoaded = false;

  HomeController(this.context) {
    Log.echo('HomeController');
  }

  @override
  initialize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkAuthState();
    });
    Log.echo('initialize');
  }

  /// Firebase Auth ログイン状態チェック
  void checkAuthState() {
    final User? currentRobot = _firebaseAuthenticationService.getRobot();
    if (currentRobot == null) {
      const LoginRoute().go(context);
    }
  }

  /// ログアウト
  void logout() {
    _firebaseAuthenticationService.signOut();
    const LoginRoute().go(context);
  }

  /// ビデオプレイヤーの初期化
  void initializeVideoPlayer(VoidCallback onInitialized) {
    videoPlayerController = VideoPlayerController.asset(
      Assets.videos.unicornShort,
    )
      ..setLooping(true)
      ..initialize().then((_) {
        onInitialized();
        videoPlayerController.setVolume(0.0);
        videoPlayerController.play();
      });
  }

  /// Google Maps JavaScript を .env のキーで動的にロード
  /// [onMapJsInitialized] はロード完了後に呼ばれるコールバック
  Future<void> initializeGoogleMapsJs(VoidCallback onMapJsInitialized) async {
    // すでにロード済みなら何もしない
    if (_googleMapsJsLoaded) {
      onMapJsInitialized();
      return;
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing GOOGLE_MAPS_API_KEY in .env');
    }

    // 重複ロードを避けるために script タグが存在しないか確認
    if (html.document.getElementById('google_maps_api') != null) {
      _googleMapsJsLoaded = true;
      onMapJsInitialized();
      return;
    }

    final script = html.ScriptElement()
      ..id = 'google_maps_api'
      ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
      ..defer = true;

    final completer = Completer<void>();
    script.onLoad.listen((_) {
      _googleMapsJsLoaded = true;
      completer.complete();
    });
    script.onError.listen((_) {
      completer.completeError('Failed to load Google Maps JS');
    });

    html.document.head?.append(script);

    // ロード完了待ち
    await completer.future;
    onMapJsInitialized();
  }

  /// 後始末
  void videoPlayerDispose() {
    videoPlayerController.dispose();
  }
}
