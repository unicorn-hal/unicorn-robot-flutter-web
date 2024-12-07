class UnicornSupport {
  final String robotSupportId;
  final String userId;

  UnicornSupport({
    required this.robotSupportId,
    required this.userId,
  });

  factory UnicornSupport.fromJson(Map<String, dynamic> json) {
    return UnicornSupport(
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
