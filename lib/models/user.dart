import 'package:hive/hive.dart';
import 'package:social_app/models/direction.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String IM;

  @HiveField(2)
  String firstName;

  @HiveField(3)
  String lastName;

  @HiveField(4)
  String email;

  @HiveField(5)
  String phone;

  @HiveField(6)
  String address;

  @HiveField(7)
  String position;

  @HiveField(8)
  String attribution;

  @HiveField(9)
  Direction? direction;

  @HiveField(10)
  DateTime entryDate;

  @HiveField(11)
  bool senator;

  @HiveField(12)
  String token;

  @HiveField(13)
  String? photo;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.IM,
    required this.phone,
    required this.address,
    required this.position,
    required this.attribution,
    required this.direction,
    required this.entryDate,
    required this.senator,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      IM: json['IM'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      position: json['position'] ?? '',
      attribution: json['attribution'] ?? '',
      direction: json['direction'] != null
          ? Direction.fromJson(json['direction'])
          : null,
      entryDate: DateTime.parse(
        json['entryDate'] ?? DateTime.now().toIso8601String(),
      ),
      senator: json['senator'],
      token: json['token'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'IM': IM,
    'phone': phone,
    'address': address,
    'position': position,
    'attribution': attribution,
    'direction': direction?.toJson(),
    'entryDate': entryDate.toIso8601String(),
    'senator': senator,
    'token': token,
    'photo': photo,
  };
}

class CreateUser {
  String firstName;
  String lastName;
  String email;
  String IM;
  String password;
  String confirmPassword;
  String phone;
  String address;
  String position;
  String attribution;
  String service;
  Direction direction;
  DateTime entryDate;
  bool senator;

  CreateUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.IM,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.address,
    required this.position,
    required this.attribution,
    required this.service,
    required this.direction,
    required this.entryDate,
    required this.senator,
  });
}
