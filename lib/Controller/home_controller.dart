// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Robot/robot.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Robot/robot_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  RobotApi get _robotApi => RobotApi();

  final ValueNotifier<bool> _wsConnectionStatus = ValueNotifier(false);
  late final Robot robot;

  BuildContext context;
  HomeController(this.context) {
    Log.echo('HomeController');
  }

  @override
  void initialize() {
    _listenWsConnectionStatus((value) {
      try {
        Log.echo('WebSocketConnectionStatus: $value');
      } catch (e) {
        Log.echo('Error: $e');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAuthState();
      await _connectWebSocket();
    });
  }

  /// ログイン状態を確認
  Future<void> _checkAuthState() async {
    try {
      final User? currentRobot = _firebaseAuthenticationService.getRobot();
      if (currentRobot == null) {
        const LoginRoute().go(context);
        return;
      }

      // ロボット情報の取得
      robot = await _getRobot(currentRobot.uid);
    } catch (e) {
      Log.echo('Error: $e');
      const LoginRoute().go(context);
    }
  }

  /// Robot情報の取得
  Future<Robot> _getRobot(String robotId) async {
    final Robot? robot = await _robotApi.getRobot(robotId);
    if (robot == null) {
      throw Exception('Failed to get robot');
    }
    return robot;
  }

  /// ログアウト
  void signOut() {
    _firebaseAuthenticationService.signOut();
    const LoginRoute().go(context);
  }

  /// WebSocket接続
  Future<void> _connectWebSocket() async {
    // String wsUrl = '${dotenv.env['UNICORN_API_BASEURL']!}ws';
    // String wsUrl = 'wss://unicorn-monorepo-384446500375.asia-east1.run.app/ws';
    String wsUrl =
        '${dotenv.env['UNICORN_API_BASEURL']!.replaceFirst(RegExp('https'), 'wss')}ws';
    final String destination = '/topic/unicorn/robots/${robot.robotId}';
    Log.echo('WebSocketURL: $wsUrl');
    Log.echo('WebSocketDestination: $destination');

    late StompClient stompClient;
    stompClient = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (StompFrame frame) async {
          Log.echo('WebSocket: Connected');
          _wsConnectionStatus.value = true;

          stompClient.subscribe(
            destination: destination,
            callback: wsCallback,
          );
        },
        onWebSocketError: (dynamic error) {
          Log.echo('WebSocket: $error');
          _wsConnectionStatus.value = false;
        },
        onDisconnect: (StompFrame frame) {
          Log.echo('WebSocket: Disconnected');
          _wsConnectionStatus.value = false;
        },
      ),
    );
    //   config: StompConfig.sockJS(
    //     url: wsUrl,
    //     onConnect: (StompFrame frame) async {
    //       Log.echo('WebSocket: Connected');
    //       _wsConnectionStatus.value = true;

    //       stompClient.subscribe(
    //         destination: destination,
    //         callback: wsCallback,
    //       );
    //     },
    //     onWebSocketError: (dynamic error) {
    //       Log.echo('WebSocket: $error');
    //       _wsConnectionStatus.value = false;
    //     },
    //     onDisconnect: (StompFrame frame) {
    //       Log.echo('WebSocket: Disconnected');
    //       _wsConnectionStatus.value = false;
    //     },
    //   ),
    // );
    stompClient.activate();
  }

  /// WebSocketコールバック
  void wsCallback(StompFrame frame) {
    Log.echo('WebSocket: ${frame.body}');
  }

  /// WebSocketの状態をListen
  void _listenWsConnectionStatus(ValueChanged<bool> callback) {
    _wsConnectionStatus.addListener(() {
      callback(_wsConnectionStatus.value);
    });
  }
}
