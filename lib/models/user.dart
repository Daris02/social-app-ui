import 'package:social_app/models/enums/bureau_permanant.dart';
import 'package:social_app/models/enums/direction.dart';
import 'package:social_app/models/enums/position.dart';
import 'package:social_app/models/enums/role.dart';

class User {
  int id;
  String IM;
  String firstName;
  String lastName;
  String email;
  String phone;
  String address;
  String? photo;
  Position position;
  String attribution;
  String? service;
  Direction? direction;
  Role role;
  DateTime entryDate;
  bool? senator;
  bool? secretaireParticullier;
  BureauPermanent? bureau;

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
    required this.service,
    required this.entryDate,
    required this.role,
    this.senator,
    this.direction,
    this.photo,
    this.bureau,
    this.secretaireParticullier,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      IM: json['IM'] ?? '',
      role: roleFromString(json['role']),
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      direction: directionFromString(json['direction']),
      position: positionFromString(json['position']) ?? Position.unknown,
      attribution: json['attribution'] ?? '',
      service: json['service'] ?? '',
      photo: json['photo'] ?? '',
      entryDate: DateTime.parse(
        json['entryDate'] ?? DateTime.now().toIso8601String(),
      ),
      senator: json['senator'],
      bureau: bureauFromString(json['bureau']),
      secretaireParticullier: json['secretaireParticullier'] ?? false,
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
    'position': position.name,
    'attribution': attribution,
    'direction': direction?.name,
    'role': role.name,
    'entryDate': entryDate.toIso8601String(),
    'senator': senator,
    'photo': photo,
    'secretaireParticullier': secretaireParticullier,
    'bureau': bureau?.name,
  };

  static Role roleFromString(String value) {
    return Role.values.firstWhere((e) => e.name == value);
  }

  static Direction? directionFromString(String? value) {
    if (value == null) return null;
    return Direction.values.firstWhere((e) => e.name == value);
  }

  static Position? positionFromString(String? value) {
    if (value == null) return null;
    return Position.values.firstWhere((e) => e.name == value);
  }

  static BureauPermanent? bureauFromString(String? value) {
    if (value == null) return null;
    return BureauPermanent.values.firstWhere((e) => e.name == value);
  }
}
