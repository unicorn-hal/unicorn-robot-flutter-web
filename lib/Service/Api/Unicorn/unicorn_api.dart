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
  Future<UnicornLocation?> postMovingUnicorn(
      {required UnicornLocation body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/moving');
      final ApiResponse response = await post(body.toJson());
      return UnicornLocation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// POST
  /// 到着通知
  /// [body] UnicornRequest
  /// [robotId] ロボットID
  Future<UnicornLocation?> postArrivalUnicorn(
      {required UnicornLocation body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/arrival');
      final ApiResponse response = await post(body.toJson());
      return UnicornLocation.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// POST
  /// 完了通知
  /// [body] UnicornResponse
  /// [robotId] ロボットID
  Future<UnicornSupport?> postCompleteUnicorn(
      {required UnicornSupport body, required String robotId}) async {
    try {
      useParameter(parameter: '/$robotId/complete');
      final ApiResponse response = await post(body.toJson());
      return UnicornSupport.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
