import 'package:unicorn_robot_flutter_web/Model/Entity/Account/account.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/api_response.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/endpoint.dart';
import 'package:unicorn_robot_flutter_web/Service/Api/Core/api_core.dart';

class AccountApi extends ApiCore with Endpoint {
  AccountApi() : super(Endpoint.accounts);

  /// GET
  Future<Account?> getAccount() async {
    try {
      final ApiResponse response = await get();
      return Account.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
}
