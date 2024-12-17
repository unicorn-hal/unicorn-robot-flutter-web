import 'package:unicorn_robot_flutter_web/Model/Entity/HealthCheckup/health_checkup.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/User/user.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/api_response.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/endpoint.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/api_core.dart';

class UserApi extends ApiCore with Endpoint {
  UserApi() : super(Endpoint.users);

  /// GET
  /// [userId] ユーザーID
  Future<User?> getUser({required String userId}) async {
    try {
      useParameter(parameter: '/$userId');
      final ApiResponse response = await get();
      return User.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  /// GET
  /// ユーザーの健康診断結果一覧取得
  /// [userId] ユーザーID
  Future<List<HealthCheckup>?> getUserHealthCheckupList(
      {required String userId}) async {
    try {
      useParameter(parameter: '/$userId/health_checkups');
      final ApiResponse response = await get();
      final List<HealthCheckup> data = (response.data['data'] as List)
          .map((e) => HealthCheckup.fromJson(e))
          .toList();
      return data;
    } catch (e) {
      return null;
    }
  }
}
