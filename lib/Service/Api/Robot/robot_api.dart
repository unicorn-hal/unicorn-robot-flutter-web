import "package:unicorn_robot_flutter_web/Constants/Enum/robot_power_status_enum.dart";
import "package:unicorn_robot_flutter_web/Model/Entity/Robot/robot.dart";
import "package:unicorn_robot_flutter_web/Model/Entity/api_response.dart";
import "package:unicorn_robot_flutter_web/Service/Api/Core/api_core.dart";
import "package:unicorn_robot_flutter_web/Service/Api/Core/endpoint.dart";
import "package:unicorn_robot_flutter_web/Service/Log/log_service.dart";

class RobotApi extends ApiCore with Endpoint {
  RobotApi() : super(Endpoint.robots);

  /// GET
  Future<Robot?> getRobot(String robotId) async {
    try {
      useParameter(parameter: "/$robotId");
      final ApiResponse response = await get();
      return Robot.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// PUT
  /// ロボットの起動状態を更新
  Future<Robot?> putRobotPower(
      String robotId, RobotPowerStatusEnum powerStatus) async {
    try {
      useParameter(parameter: "/$robotId/power");
      final ApiResponse response = await put({
        "status": powerStatus.value,
      });
      Log.echo("response: ${response.data}");
      return Robot.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
