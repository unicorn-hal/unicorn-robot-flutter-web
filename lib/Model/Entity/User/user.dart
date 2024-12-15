import 'package:intl/intl.dart';
import 'package:unicorn_robot_flutter_web/Constants/Enum/user_gender_enum.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final UserGenderEnum gender;
  final DateTime birthDate;
  final String address;
  final String postalCode;
  final String phoneNumber;
  final String? iconImageUrl;
  final double bodyHeight;
  final double bodyWeight;
  final String occupation;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.address,
    required this.postalCode,
    required this.phoneNumber,
    required this.iconImageUrl,
    required this.bodyHeight,
    required this.bodyWeight,
    required this.occupation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userID'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      gender: UserGenderType.fromString(json['gender']),
      birthDate: DateFormat('yyyy-MM-dd').parse(json['birthDate']),
      address: json['address'],
      postalCode: json['postalCode'],
      phoneNumber: json['phoneNumber'],
      iconImageUrl: json['iconImageUrl'],
      bodyHeight: json['bodyHeight'],
      bodyWeight: json['bodyWeight'],
      occupation: json['occupation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': UserGenderType.toStringValue(gender),
      'birthDate': DateFormat('yyyy-MM-dd').format(birthDate),
      'address': address,
      'postalCode': postalCode,
      'phoneNumber': phoneNumber,
      'iconImageUrl': iconImageUrl,
      'bodyHeight': bodyHeight,
      'bodyWeight': bodyWeight,
      'occupation': occupation,
    };
  }
}
