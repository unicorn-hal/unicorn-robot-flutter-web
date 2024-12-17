class EmergencyQueue {
  final String robotSupportId;
  final String userId;
  final double userLatitude;
  final double userLongitude;
  final String fcmTokenId;

  EmergencyQueue({
    required this.robotSupportId,
    required this.userId,
    required this.userLatitude,
    required this.userLongitude,
    required this.fcmTokenId,
  });

  factory EmergencyQueue.fromJson(Map<String, dynamic> json) {
    return EmergencyQueue(
      robotSupportId: json['robotSupportID'],
      userId: json['userID'],
      userLatitude: json['userLatitude'],
      userLongitude: json['userLongitude'],
      fcmTokenId: json['fcmTokenID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'robotSupportID': robotSupportId,
      'userID': userId,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'fcmTokenID': fcmTokenId,
    };
  }
}
