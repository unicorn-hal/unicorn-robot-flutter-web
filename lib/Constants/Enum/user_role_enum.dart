enum UserRoleEnum {
  user,
  doctor,
  robot,
}

class UserRoleType {
  static UserRoleEnum fromString(String value) {
    switch (value) {
      case 'user':
        return UserRoleEnum.user;
      case 'doctor':
        return UserRoleEnum.doctor;
      case 'robot':
        return UserRoleEnum.robot;
      default:
        throw Exception('Unknown type: $value');
    }
  }

  static String toStringValue(UserRoleEnum value) {
    switch (value) {
      case UserRoleEnum.user:
        return 'user';
      case UserRoleEnum.doctor:
        return 'doctor';
      case UserRoleEnum.robot:
        return 'robot';
      default:
        throw Exception('Unknown type: $value');
    }
  }
}
