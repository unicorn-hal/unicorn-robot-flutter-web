// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:unicorn_robot_flutter_web/Constants/Enum/robot_power_status_enum.dart';
import 'package:unicorn_robot_flutter_web/Controller/Core/controller_core.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Emergency/WebSocket/emergency_queue.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/HealthCheckup/health_checkup.dart';
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
  List<HealthCheckup>? healthCheckUpList;

  List<EmergencyQueue> emergencyQueueList = [];
  bool isProcessing = false;

  final LatLng unicornInitialPosition = const LatLng(35.681236, 139.767125);
  late final ValueNotifier<LatLng> unicornPositionNotifier;

  late VideoPlayerController videoPlayerController;
  final BuildContext context;

  // Google Maps JS ロード状態
  bool _googleMapsJsLoaded = false;

  // Polyline Completer
  Completer<List<LatLng>>? _polylineCompleter;

  HomeController(this.context) {
    Log.echo('HomeController');
  }

  @override
  void initialize() {
    unicornPositionNotifier = ValueNotifier(unicornInitialPosition);
    _wsConnectionStatus.value = false;

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
      EmergencyQueue emergencyQueue = EmergencyQueue.fromJson(json);

      /// キューをリストに追加
      emergencyQueueList.add(emergencyQueue);

      /// 処理中でなければ次のキューを処理
      if (!isProcessing) {
        await _processNextQueue();
      }
    } catch (e) {
      Log.echo('Error: $e');
    }
  }

  /// 次のキューを処理
  Future<void> _processNextQueue() async {
    if (emergencyQueueList.isEmpty) {
      isProcessing = false;
      return;
    }

    isProcessing = true;

    final emergencyQueue = emergencyQueueList.first;

    /// Unicornの初期位置
    unicornPositionNotifier.value = unicornInitialPosition;

    /// User情報の取得
    await getUser(emergencyQueue.userId);
    await getCheckupResult(emergencyQueue.userId);

    _emergencyQueueNotifier.value = emergencyQueue;

    // Polyline Completerを初期化
    _polylineCompleter = Completer<List<LatLng>>();

    // ViewにPolylineの準備を促し、PolyLineが提供されるのを待つ
    List<LatLng> polyline = await _polylineCompleter!.future;

    // ポリラインを取得したらキュータスクを開始
    await queueTask(polyline: polyline);
  }

  /// ViewからPolylineを提供
  void providePolyline(List<LatLng> polyline) {
    if (_polylineCompleter != null && !_polylineCompleter!.isCompleted) {
      _polylineCompleter!.complete(polyline);
    }
  }

  /// EmergencyQueueのタスク消化
  Future<void> queueTask({required List<LatLng> polyline}) async {
    if (_emergencyQueueNotifier.value == null || polyline.isEmpty) {
      return;
    }

    int steps = polyline.length >= 10 ? 10 : polyline.length;
    List<LatLng> thinnedPolyline = [];
    int interval = steps > 0 ? (polyline.length / steps).floor() : 1;
    interval = interval > 0 ? interval : 1;

    for (int i = 0; i < polyline.length; i += interval) {
      thinnedPolyline.add(polyline[i]);
      if (thinnedPolyline.length == steps) {
        break;
      }
    }

    if (thinnedPolyline.length < steps && polyline.isNotEmpty) {
      thinnedPolyline.add(polyline.last);
    }

    // 最終到着地点を追加
    thinnedPolyline.add(LatLng(_emergencyQueueNotifier.value!.userLatitude,
        _emergencyQueueNotifier.value!.userLongitude));

    // 移動処理
    for (LatLng point in thinnedPolyline) {
      unicornPositionNotifier.value = point;

      final UnicornLocation step = UnicornLocation(
        userId: _emergencyQueueNotifier.value!.userId,
        robotLatitude: unicornPositionNotifier.value.latitude,
        robotLongitude: unicornPositionNotifier.value.longitude,
      );
      await movingUnicorn(step);
      await Future.delayed(const Duration(seconds: 1));
    }

    // 到着通知
    await arrivalUnicorn(
      UnicornLocation(
        userId: _emergencyQueueNotifier.value!.userId,
        robotLatitude: unicornPositionNotifier.value.latitude,
        robotLongitude: unicornPositionNotifier.value.longitude,
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

      // キューを更新
      emergencyQueueList.removeAt(0);
      _emergencyQueueNotifier.value = null;

      // 次のキューを処理
      if (emergencyQueueList.isNotEmpty) {
        await _processNextQueue();
      } else {
        isProcessing = false;
      }
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
      healthCheckUpList =
          await _userApi.getUserHealthCheckupList(userId: userId);
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
    unicornPositionNotifier.dispose();
    html.document
        .removeEventListener('visibilitychange', _handleVisibilityChange);
    await _robotApi.putRobotPower(
        robot.robotId, RobotPowerStatusEnum.robotWaiting);
  }
}
