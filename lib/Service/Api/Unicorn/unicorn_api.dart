import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_request.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Unicorn/unicorn_response.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/api_response.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/api_core.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/endpoint.dart';

class UnicornApi extends ApiCore with Endpoint {
  UnicornApi() : super(Endpoint.unicorn);

  /// POST
  /// 移動通知
  /// [body] UnicornRequest
  /// [robotId] ロボットID
  Future<int> postMovingUnicorn(
      {required UnicornRequest body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/moving');
      final ApiResponse response = await post(body.toJson());
      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  /// POST
  /// 到着通知
  /// [body] UnicornRequest
  /// [robotId] ロボットID
  Future<int> postArrivalUnicorn(
      {required UnicornRequest body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/arrival');
      final ApiResponse response = await post(body.toJson());
      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }

  /// POST
  /// 完了通知
  /// [body] UnicornResponse
  /// [robotId] ロボットID
  Future<int> postCompleteUnicorn(
      {required UnicornResponse body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/complete');
      final ApiResponse response = await post(body.toJson());
      return response.statusCode;
    } catch (e) {
      return 500;
    }
  }
}
