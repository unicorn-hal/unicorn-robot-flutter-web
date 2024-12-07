class UnicornResponse {
  final String robotSupportId;
  final String userId;

  UnicornResponse({
    required this.robotSupportId,
    required this.userId,
  });

  factory UnicornResponse.fromJson(Map<String, dynamic> json) {
    return UnicornResponse(
      robotSupportId: json['robotSupportID'],
      userId: json['userID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'robotSupportID': robotSupportId,
      'userID': userId,
    };
  }
}
