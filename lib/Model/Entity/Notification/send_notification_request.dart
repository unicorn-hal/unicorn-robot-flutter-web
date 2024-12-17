class SendNotificationRequest {
  final String title;
  final String body;
  final String fcmTokenId;

  SendNotificationRequest({
    required this.title,
    required this.body,
    required this.fcmTokenId,
  });

  factory SendNotificationRequest.fromJson(Map<String, dynamic> json) {
    return SendNotificationRequest(
      title: json['title'],
      body: json['body'],
      fcmTokenId: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'token': fcmTokenId,
    };
  }
}
