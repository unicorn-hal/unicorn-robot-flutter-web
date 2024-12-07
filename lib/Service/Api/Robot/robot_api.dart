import "package:unicorn_robot_flutter_web/Model/Entity/Robot/robot.dart";
import "package:unicorn_robot_flutter_web/Model/Entity/api_response.dart";
import "package:unicorn_robot_flutter_web/Service/Api/Core/api_core.dart";
import "package:unicorn_robot_flutter_web/Service/Api/Core/endpoint.dart";

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
}
