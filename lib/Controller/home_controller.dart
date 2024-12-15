// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:unicorn_robot_flutter_web/Constants/Enum/robot_power_status_enum.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Emergency/WebSocket/emergency_queue.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Notification/send_notification_request.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Robot/robot.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_location.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_support.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/User/user.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Robot/robot_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Unicorn/unicorn_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/User/user_api.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Notification/notification_service.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
import 'package:video_player/video_player.dart';

class HomeController extends ControllerCore {
  FirebaseAuthenticationService get _firebaseAuthService =>
      FirebaseAuthenticationService();
  NotificationService get _notificationService => NotificationService();
  UserApi get _userApi => UserApi();
  RobotApi get _robotApi => RobotApi();
  UnicornApi get _unicornApi => UnicornApi();

  final ValueNotifier<bool> _wsConnectionStatus = ValueNotifier(false);
  final ValueNotifier<EmergencyQueue?> _emergencyQueueNotifier =
      ValueNotifier(null);
  late final Robot robot;
  User? user;

  final double unicornInitialLatitude = 35.681236;
  final double unicornInitialLongitude = 139.767125;

  late double unicornLatitude;
  late double unicornLongitude;

  late VideoPlayerController videoPlayerController;
  final BuildContext context;

  // Google Maps JS ロード状態
  bool _googleMapsJsLoaded = false;

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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAuthState();
      await _connectWebSocket();
      await _robotApi.putRobotPower(
          robot.robotId, RobotPowerStatusEnum.robotWaiting);
      html.document
          .addEventListener('visibilitychange', _handleVisibilityChange);
    });
  }

  ValueNotifier<EmergencyQueue?> get emergencyQueueNotifier =>
      _emergencyQueueNotifier;

  /// ログイン状態を確認
  Future<void> _checkAuthState() async {
    try {
      final auth.User? currentRobot = _firebaseAuthService.getRobot();
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
  void _handleVisibilityChange(html.Event event) async {
    try {
      RobotPowerStatusEnum status = html.document.hidden ?? false
          ? RobotPowerStatusEnum.shutdown
          : RobotPowerStatusEnum.robotWaiting;
      Log.echo('VisibilityChange: ${status.value}');
      final res = await _robotApi.putRobotPower(robot.robotId, status);
      if (res == null) {
        throw Exception('Failed to put robot power');
      }
      Log.echo('RobotPowerStatus: ${res.robotStatus.value}');
    } catch (e) {
      Log.echo('Error: $e');
    }
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

    final apiKey = dotenv.env['GOOGLE_MAP_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Missing GOOGLE_MAP_API_KEY in .env');
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

      /// Unicornの初期位置
      unicornLatitude = unicornInitialLatitude;
      unicornLongitude = unicornInitialLongitude;

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

    int steps = 10;
    double latStep = (userLatitude - unicornLatitude) / steps;
    double lonStep = (userLongitude - unicornLongitude) / steps;

    Log.echo('UserLocation: $userLatitude, $userLongitude');
    Log.echo('UnicornLocation: $unicornLatitude, $unicornLongitude');
    Log.echo('Step: $latStep, $lonStep');

    for (int i = 1; i < steps; i++) {
      unicornLatitude += latStep;
      unicornLongitude += lonStep;

      final UnicornLocation step = UnicornLocation(
        userId: _emergencyQueueNotifier.value!.userId,
        robotLatitude: unicornLatitude,
        robotLongitude: unicornLongitude,
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

  /// Robot情報の取得
  Future<Robot> _getRobot(String robotId) async {
    final Robot? robot = await _robotApi.getRobot(robotId);
    if (robot == null) {
      throw Exception('Failed to get robot');
    }
    return robot;
  }

  /// User情報の取得
  Future<void> getUser(String userId) async {
    try {
      user = await _userApi.getUser(userId: userId);
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// Userの検診結果を取得
  Future<void> getCheckupResult(String userId) async {
    try {
      // await _userApi.getUserHealthCheckupList(userId: userId);
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// 要請者に通知を送信
  Future<void> sendNotification(SendNotificationRequest request) async {
    try {
      if (user == null) {
        return;
      }

      final res = await _notificationService.sendNotification(request);

      if (res != 200) {
        throw Exception('Failed to send notification');
      }
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// ログアウト
  void signOut() {
    _firebaseAuthService.signOut();
    const LoginRoute().go(context);
  }

  /// Dispose
  void dispose() async {
    Log.echo('dispose');
    videoPlayerController.dispose();
    _wsConnectionStatus.dispose();
    html.document
        .removeEventListener('visibilitychange', _handleVisibilityChange);
    await _robotApi.putRobotPower(
        robot.robotId, RobotPowerStatusEnum.robotWaiting);
  }
}
