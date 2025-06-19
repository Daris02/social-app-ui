import 'package:social_app/models/direction.dart';

class User {
  int id;

  String IM;

  String firstName;

  String lastName;

  String email;

  String phone;

  String address;

  String position;

  String attribution;

  Direction? direction;

  DateTime entryDate;

  bool senator;

  String token;

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
    required this.entryDate,
    required this.senator,
    required this.token,
    this.direction,
    this.photo,
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
      photo: json['photo'] ?? '',
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
