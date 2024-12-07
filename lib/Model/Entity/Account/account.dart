import 'package:unicorn_robot_flutter_web/Constants/Enum/user_role_enum.dart';
import 'package:unicorn_robot_flutter_web/Model/Entity/Account/account_request.dart';

class Account {
  final String uid;
  final UserRoleEnum role;
  final String fcmTokenId;

  Account({
    required this.uid,
    required this.role,
    required this.fcmTokenId,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      uid: json['uid'],
      role: UserRoleType.fromString(json['role']),
      fcmTokenId: json['fcmTokenId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': UserRoleType.toStringValue(role),
      'fcmTokenId': fcmTokenId,
    };
  }

  AccountRequest toRequest() {
    return AccountRequest.fromJson(toJson());
  }
}
