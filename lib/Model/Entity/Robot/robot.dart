class Robot {
  final String robotId;
  final String robotName;

  Robot({
    required this.robotId,
    required this.robotName,
  });

  factory Robot.fromJson(Map<String, dynamic> json) {
    return Robot(
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
