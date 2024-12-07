class UnicornLocation {
  final String userId;
  final double robotLatitude;
  final double robotLongitude;

  UnicornLocation({
    required this.userId,
    required this.robotLatitude,
    required this.robotLongitude,
  });

  factory UnicornLocation.fromJson(Map<String, dynamic> json) {
    return UnicornLocation(
      userId: json['userID'],
      robotLatitude: json['robotLatitude'],
      robotLongitude: json['robotLongitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'robotLatitude': robotLatitude,
      'robotLongitude': robotLongitude,
    };
  }
}
