enum UserGenderEnum {
  male,
  female,
  other,
}

extension UserGenderEnumExtension on UserGenderEnum {
  String get value {
    switch (this) {
      case UserGenderEnum.male:
        return 'male';
      case UserGenderEnum.female:
        return 'female';
      case UserGenderEnum.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case UserGenderEnum.male:
        return '男性';
      case UserGenderEnum.female:
        return '女性';
      case UserGenderEnum.other:
        return 'その他';
    }
  }

  static UserGenderEnum fromString(String value) {
    switch (value) {
      case 'male':
        return UserGenderEnum.male;
      case 'female':
        return UserGenderEnum.female;
      case 'other':
        return UserGenderEnum.other;
      default:
        throw Exception('Unknown UserGenderEnum value: $value');
    }
  }
}
