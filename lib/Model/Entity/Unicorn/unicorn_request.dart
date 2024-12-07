class UnicornRequest {
  final String userId;
  final double robotLatitute;
  final double robotLongitude;

  UnicornRequest({
    required this.userId,
    required this.robotLatitute,
    required this.robotLongitude,
  });

  factory UnicornRequest.fromJson(Map<String, dynamic> json) {
    return UnicornRequest(
      userId: json['userID'],
      robotLatitute: json['robotLatitute'],
      robotLongitude: json['robotLongitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'robotLatitute': robotLatitute,
      'robotLongitude': robotLongitude,
    };
  }
}
