import 'package:unicorn_robot_flutter_web/Constants/Enum/robot_power_status_enum.dart';

class Robot {
  final String robotId;
  final String robotName;
  final RobotPowerStatusEnum robotStatus;

  Robot({
    required this.robotId,
    required this.robotName,
    required this.robotStatus,
  });

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
      robotId: json['robotID'],
      robotName: json['robotName'],
      robotStatus: RobotPowerStatusEnumExtension.fromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'robotID': robotId,
      'robotName': robotName,
      'status': robotStatus.value,
    };
  }
}
