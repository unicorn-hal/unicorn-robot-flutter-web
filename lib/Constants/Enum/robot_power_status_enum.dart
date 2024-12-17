enum RobotPowerStatusEnum {
  robotWaiting,
  shutdown,
}

extension RobotPowerStatusEnumExtension on RobotPowerStatusEnum {
  String get value {
    switch (this) {
      case RobotPowerStatusEnum.robotWaiting:
        return 'robot_waiting';
      case RobotPowerStatusEnum.shutdown:
        return 'shutdown';
    }
  }

  static RobotPowerStatusEnum fromString(String value) {
    switch (value) {
      case 'robot_waiting':
        return RobotPowerStatusEnum.robotWaiting;
      case 'shutdown':
        return RobotPowerStatusEnum.shutdown;
      default:
        throw Exception('Unknown RobotPowerStatusEnum value: $value');
    }
  }
}
