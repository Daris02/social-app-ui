
import 'package:social_app/models/enums/bureau_permanant.dart';
import 'package:social_app/models/enums/direction.dart';
import 'package:social_app/models/enums/position.dart';

class CreateUser {
  String firstName;
  String lastName;
  String email;
  String IM;
  String password;
  String confirmPassword;
  String phone;
  String address;
  String? photo;
  Position? position;
  String attribution;
  String service;
  Direction direction;
  DateTime entryDate;
  bool? senator;
  bool? secretaireParticullier;
  BureauPermanent? bureau;

  CreateUser({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.IM,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.address,
    this.photo,
    this.position,
    required this.attribution,
    required this.service,
    required this.direction,
    required this.entryDate,
    this.senator,
    this.secretaireParticullier,
    this.bureau,
  });
}
