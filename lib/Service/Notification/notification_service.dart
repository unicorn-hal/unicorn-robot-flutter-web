import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:unicorn_robot_flutter_web/Model/Entity/Notification/send_notification_request.dart';
import 'package:unicorn_robot_flutter_web/Service/Firebase/Authentication/authentication_service.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class NotificationService {
  FirebaseAuthenticationService get authService =>
      FirebaseAuthenticationService();

  final String _baseUrl = dotenv.env['NOTIFICATION_SERVER_URL']!;
  late Map<String, String> _headers;

  /// ヘッダー作成
  Future<void> makeHeader() async {
    String idToken = await authService.getIdToken() ?? '';
    _headers = {
      'Content-type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };
  }

  /// POST /send
  Future<int> sendNotification(SendNotificationRequest request) async {
    try {
      await makeHeader();
      http.Response response = await http.post(
        Uri.parse('$_baseUrl/send'),
        headers: _headers,
        body: request.toJson(),
      );
      return response.statusCode;
    } catch (e) {
      Log.echo('Error: $e');
      return 500;
    }
  }
}
