// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Emergency/WebSocket/emergency_queue.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Robot/robot.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_location.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_support.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Robot/robot_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Unicorn/unicorn_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class HomeController extends ControllerCore {
  final FirebaseAuthenticationService _firebaseAuthenticationService =
      FirebaseAuthenticationService();
  RobotApi get _robotApi => RobotApi();
  UnicornApi get _unicornApi => UnicornApi();

  final ValueNotifier<bool> _wsConnectionStatus = ValueNotifier(false);
  final ValueNotifier<EmergencyQueue?> _emergencyQueueNotifier =
      ValueNotifier(null);
  late final Robot robot;

  final double unicornInitialLatitude = 35.681236;
  final double unicornInitialLongitude = 139.767125;

  late double unicornLatitude;
  late double unicornLongitude;

  BuildContext context;
  HomeController(this.context) {
    Log.echo('HomeController');
  }

  @override
  void initialize() {
    _wsConnectionStatus.value = false;

    _listenWsConnectionStatus((value) {
      try {
        Log.echo('WebSocketConnectionStatus: $value');
      } catch (e) {
        Log.echo('Error: $e');
      }
    });

    unicornLatitude = unicornInitialLatitude;
    unicornLongitude = unicornInitialLongitude;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAuthState();
      await _connectWebSocket();
      document.addEventListener('visibilitychange', _handleVisibilityChange);
    });
  }

  ValueNotifier<EmergencyQueue?> get emergencyQueueNotifier =>
      _emergencyQueueNotifier;

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

  /// タブの表示状態を監視
  void _handleVisibilityChange(Event event) {
    if (document.hidden ?? false) {
      Log.echo('hidden');
    } else {
      Log.echo('visible');
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
    stompClient.activate();
  }

  /// WebSocketコールバック
  void wsCallback(StompFrame frame) async {
    try {
      Log.echo('WebSocket: ${frame.body}');
      final Map<String, dynamic> json =
          jsonDecode(frame.body!) as Map<String, dynamic>;
      _emergencyQueueNotifier.value = EmergencyQueue.fromJson(json);

      await queueTask();
    } catch (e) {
      Log.echo('Error: $e');
      _emergencyQueueNotifier.value = null;
    }
  }

  /// WebSocketの状態をListen
  void _listenWsConnectionStatus(ValueChanged<bool> callback) {
    _wsConnectionStatus.addListener(() {
      callback(_wsConnectionStatus.value);
    });
  }

  /// EmergencyQueueのタスク消化
  Future<void> queueTask() async {
    if (_emergencyQueueNotifier.value == null) {
      return;
    }

    double userLatitude = _emergencyQueueNotifier.value!.userLatitude;
    double userLongitude = _emergencyQueueNotifier.value!.userLongitude;

    double latStep = (userLatitude - unicornLatitude) / 5;
    double lonStep = (userLongitude - unicornLongitude) / 5;

    for (int i = 1; i <= 5; i++) {
      final UnicornLocation step = UnicornLocation(
        userId: _emergencyQueueNotifier.value!.userId,
        robotLatitude: unicornLatitude - latStep * i,
        robotLongitude: unicornLongitude - lonStep * i,
      );
      await movingUnicorn(step);
      await Future.delayed(const Duration(seconds: 1));
    }
    await arrivalUnicorn(
      UnicornLocation(
        userId: _emergencyQueueNotifier.value!.userId,
        robotLatitude: userLatitude,
        robotLongitude: userLongitude,
      ),
    );
    await Future.delayed(const Duration(seconds: 5));
    await completeSupport();
  }

  /// 移動通知API
  Future<void> movingUnicorn(UnicornLocation unicornLocation) async {
    if (_emergencyQueueNotifier.value == null) {
      return;
    }

    try {
      await _unicornApi.postMovingUnicorn(
        body: unicornLocation,
        robotId: robot.robotId,
      );
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// 到着通知API
  Future<void> arrivalUnicorn(UnicornLocation unicornLocation) async {
    if (_emergencyQueueNotifier.value == null) {
      return;
    }

    try {
      await _unicornApi.postArrivalUnicorn(
        body: unicornLocation,
        robotId: robot.robotId,
      );
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// 対応完了API
  Future<void> completeSupport() async {
    if (_emergencyQueueNotifier.value == null) {
      return;
    }

    try {
      await _unicornApi.postCompleteUnicorn(
        body: UnicornSupport(
          robotSupportId: _emergencyQueueNotifier.value!.robotSupportId,
          userId: _emergencyQueueNotifier.value!.userId,
        ),
        robotId: robot.robotId,
      );
      _emergencyQueueNotifier.value = null;
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// Dispose
  void dispose() {
    Log.echo('dispose');
    _wsConnectionStatus.dispose();
    document.removeEventListener('visibilitychange', _handleVisibilityChange);
  }
}
