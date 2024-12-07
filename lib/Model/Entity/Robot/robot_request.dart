class RobotRequest {
  final String robotId;
  final String robotName;

  RobotRequest({
    required this.robotId,
    required this.robotName,
  });

  factory RobotRequest.fromJson(Map<String, dynamic> json) {
    return RobotRequest(
      robotId: json['robotID'],
      robotName: json['robotName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'robotID': robotId,
      'robotName': robotName,
    };
  }
}
